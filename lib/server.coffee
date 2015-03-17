#
# Ethan Mick
# 2015
#
Hapi = require 'Hapi'
Q = require 'q'
SocketIO = require 'socket.io'
log = require './helpers/log'
Scheduler = require './models/scheduler'

class Server

  constructor: (opts)->
    @server = new Hapi.Server()
    @server.connection(opts)
    @scheduler = new Scheduler()
    @scheduler.on 'task', @_send.bind(this)
    @pool = {}
    @io = SocketIO.listen(@server.listener)
    @io.sockets.on 'connection', (socket)=>

      @pool[socket.id] = socket
      log.warn 'Client connected', socket.id

      socket.on 'disconnect', =>
        delete @pool[socket.id]
        log.warn 'client disconnected', socket.id

  _send: (t)->
    key = Object.keys(@pool)[0]
    if key
      socket = @pool[key]
      socket.emit( 'task', t.toObject() )
      t.removeQ()


  routes: ->
    register = Q.nbind(@server.register, @server)
    register({
      register: require('hapi-router-coffee')
      options:
        routesDir: "#{__dirname}/routes/"
    })

  start: ->
    Q.nbind(@server.start, @server)().then =>
      @scheduler.start()

  stop: ->
    Q.nbind(@server.stop, @server)()

module.exports = Server
