'use strict'
#
#
#
#
should = require('chai').should()
net = require 'net'
Server = require '../../lib/server'
mongo = require '../../lib/helpers/mongo'
mongoose = require('mongoose-q')()
Task = require '../../lib/models/task'
uuid = require 'uuid'
SocketIO = require('socket.io-client')

describe 'Server', ->

  before (done)->
    mongo().then -> done()

  server = null
  beforeEach (done)->
    server = new Server(port: 4567)
    server.start().then ->
      server.routes()
    .then ->
      done()
    .done()

  it 'should accept a TCP connection', (done)->
    client = SocketIO('http://localhost:4567', multiplex: no)
    client.on 'connect', ->
      client.disconnect()

    client.on 'disconnect', ->
      done()
      client = null

  taskName = "test-#{uuid.v4()}"
  it 'should make a new task', (done)->
    date = new Date()
    date.setMinutes(date.getMinutes() + 30)
    task =
      name: taskName
      time: date
      opts:
        some: 'data'

    req =
      method: 'POST'
      url: '/v1/task'
      payload: JSON.stringify(task)

    server.server.inject req, (res)->
      should.not.exist res.result.error
      res.statusCode.should.equal 200

      Task.findOneQ(name: task.name).then (t)->
        should.exist t
        t.updated_at.should.be.ok
        t.created_at.should.be.ok
        done()

  it 'should fetch the task', (done)->
    req =
      method: 'GET'
      url: "/v1/task/#{taskName}"

    server.server.inject req, (res)->
      should.not.exist res.result.error
      t = res.result
      should.exist t
      t.updated_at.should.be.ok
      t.created_at.should.be.ok
      t.name.should.equal taskName
      done()

  it 'should delete the task', (done)->
    req =
      method: 'DELETE'
      url: "/v1/task/#{taskName}"

    server.server.inject req, (res)->
      should.not.exist res.result.error
      res.statusCode.should.equal 200

      Task.findOneQ(name: taskName).then (t)->
        should.not.exist t
        done()

  it 'should fire off a task when it has occured', (done)->
    # insert a task
    date = new Date()
    date.setSeconds(date.getSeconds() - 1) #just occured
    task =
      name: uuid.v4()
      time: date

    opts =
      name: uuid.v4()
      time: date

    client = SocketIO('http://localhost:4567', multiplex: no)

    client.on 'task', (t)->
      t.time = new Date(t.time)
      t.name.should.equal opts.name
      t.time.getTime().should.equal opts.time.getTime()
      client.disconnect()

    client.on 'disconnect', ->
      done()

    client.on 'connect', ->
      t = new Task(opts)
      server.scheduler.queue.enq(t)

  afterEach (done)->
    server.stop().then ->
      done()

  after (done)->
    mongoose.connection.close ->
      done()
