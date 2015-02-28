'use strict'
#
# Ethan Mick
# 2015
#
Q = require 'Q'
TCPServer = require('net').Server
jsonstream = require 'json-stream'
log = require '../helpers/log'
Task = require './task'

class Server extends TCPServer

  constructor: ->
    super(@_connection)

  _connection: (c)->
    log.warn 'Client connected'

    c.on 'end', ->
      log.warn 'client disconnected'

    stream = jsonstream()
    stream.on 'data', (data)=>
      log.info 'DATA', data
      if data?.command is 'create'
        @createTask(data?.attributes, c)

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
    Task.removeQ(opts).then ->
      c.write('200')
    .fail (err)->
      c.write('400')
    .done()

  getTask: (name, c)->
    Task.findOneQ(name: name).then (task)->
      return c.write('404') unless task
      c.write(task.toObject())
    .fail (err)->
      c.write('400')
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
