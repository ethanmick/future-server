'use strict'
#
# Ethan Mick
# 2015
#
Q = require 'Q'
TCPServer = require('net').Server
jsonstream = require 'json-stream'
log = require '../helpers/log'

class Server extends TCPServer

  constructor: ->
    super(@_connection)

  _connection: (c)->
    log.warn 'Client connected'

    c.on 'end', ->
      log.warn 'client disconnected'

    stream = jsonstream()
    stream.on 'data', (data)->
      log.info 'DATA', data
    c.pipe(stream)

  _listen: (port)->
    listen = Q.nbind(@listen, this)
    listen(port)

  _close: ->
    close = Q.nbind(@close, this)
    close()

module.exports = Server
