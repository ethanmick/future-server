'use strict'
#
#
#
should = require('chai').should()
net = require 'net'
Server = require '../../lib/models/server'
mongo = require '../../lib/helpers/mongo'
mongoose = require('mongoose-q')()
Task = require '../../lib/models/task'
uuid = require 'uuid'

describe 'Server', ->

  before (done)->
    mongo().then -> done()

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

  it 'should send json data', (done)->
    client = net.createConnection port: 4567, (c)->
      data =
        some:
          ok: 'data'
        cool: 'man'
        awesome:
          sauce:
            yep: 'woot'

      client.end(JSON.stringify(data))
    client.on 'close', ->
      done()

  it 'should make a new task', (done)->
    date = new Date()
    date.setMinutes(date.getMinutes() + 30)
    task =
      name: "test-#{uuid.v4()}"
      time: date
      opts:
        some: 'data'

    client = net.createConnection port: 4567, (c)->
      msg =
        command: 'create'
        attributes: task
      client.write(JSON.stringify(msg))

    client.setEncoding('utf8')
    client.on 'data', (data)->
      data = JSON.parse(data)
      should.not.exist data.error
      data.code.should.equal 200
      client.end()

    client.on 'close', ->
      Task.findOneQ(name: task.name).then (t)->
        should.exist t
        t.updated_at.should.be.ok
        t.created_at.should.be.ok
        done()

  afterEach (done)->
    server._close().then ->
      done()

  after (done)->
    mongoose.connection.close ->
      done()
