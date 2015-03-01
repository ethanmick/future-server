'use strict'
#
# Ethan Mick
# 2015
#
Q = require 'Q'
uuid = require 'uuid'
TCPServer = require('net').Server
jsonstream = require 'json-stream'
log = require '../helpers/log'
Task = require './task'
Scheduler = require './scheduler'

class Server extends TCPServer

  constructor: ->
    super(@_connection)
    @scheduler = new Scheduler()
    @pool = {}

    @scheduler.on 'task', @_send.bind(this)

  start: ->
    @scheduler.start()

  _send: (t)->
    console.log this
    # TODO: move this to a class
    key = Object.keys(@pool)[0]
    if key
      c = @pool[key]
      c.write(@compress(execute: t.toObject()))
      t.removeQ()

  _connection: (c)->
    c.id = uuid.v4()
    @pool[c.id] = c
    log.warn 'Client connected', c.id

    c.on 'end', =>
      delete @pool[c.id]
      log.warn 'client disconnected', c.id

    stream = jsonstream()
    stream.on 'data', (data)=>
      log.info 'DATA', data
      if data?.command is 'create'
        @createTask(data?.attributes, c)
      else if data?.command is 'get'
        @getTask(data?.name, c)
      else if data?.command is 'delete'
        @deleteTask(data?.name, c)
      else
        log.error 'Invalid command received!'
    c.pipe(stream)

  ###
  * Creates a task and returns the response to the socket
  ###
  createTask: (opts, c)->
    task = new Task(opts)
    console.log 'made', task
    task.saveQ().then =>
      c.write(@compress(code: 200))
    .fail (err)=>
      c.write(@compress(error: err?.message))
    .done()

  deleteTask: (opts, c)->
    Task.removeQ(opts).then =>
      c.write(@compress(code: 200))
    .fail (err)=>
      c.write(@compress(error: err?.message))
    .done()

  getTask: (name, c)->
    Task.findOneQ(name: name).then (task)=>
      return c.write(@compress(error: 'Not Found!')) unless task
      c.write(@compress(task: task.toObject()))
    .fail (err)=>
      c.write(@compress(error: err?.message))
    .done()

  compress: (obj)->
    JSON.stringify(obj)

  _listen: (port)->
    listen = Q.nbind(@listen, this)
    listen(port)

  _close: ->
    close = Q.nbind(@close, this)
    close()

module.exports = Server
