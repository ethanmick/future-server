'use strict'
#
#
#
should = require('chai').should()
net = require 'net'
Server = require '../../lib/models/server'

describe 'Server', ->

  server = null
  beforeEach (done)->
    server = new Server()
    server._listen(4567).then ->
      done()

  it 'should accept a TCP connection', (done)->
    client = net.createConnection port: 4567, (c)->
      client.end()

    client.on 'close', ->
      done()

  afterEach (done)->
    server._close().then ->
      done()
