'use strict'
#
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

  taskName = "test-#{uuid.v4()}"
  it 'should make a new task', (done)->
    date = new Date()
    date.setMinutes(date.getMinutes() + 30)
    task =
      name: taskName
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

  it 'should fetch the task', (done)->
    client = net.createConnection port: 4567, (c)->
      packet =
        command: 'get'
        name: taskName
      client.write(JSON.stringify(packet))

    client.setEncoding('utf8')
    client.on 'data', (data)->
      data = JSON.parse(data)
      should.not.exist data.error
      t = data.task
      should.exist t
      t.updated_at.should.be.ok
      t.created_at.should.be.ok
      t.name.should.equal taskName
      client.end()

    client.on 'close', ->
      done()

  it 'should delete the task', (done)->
    client = net.createConnection port: 4567, (c)->
      packet =
        command: 'delete'
        name: taskName
      client.write(JSON.stringify(packet))

    client.setEncoding('utf8')
    client.on 'data', (data)->
      data = JSON.parse(data)
      should.not.exist data.error
      data.code.should.equal 200
      client.end()

    client.on 'close', ->
      Task.findOneQ(name: taskName).then (t)->
        should.not.exist t
        done()

  it 'should fire off a task when it has occured', (done)->
    # insert a task
    date = new Date()
    date.setSeconds(date.getSeconds() - 1) #just occured
    opts =
      name: uuid.v4()
      time: date

    client = net.createConnection port: 4567, (c)->
      this

    client.setEncoding('utf8')
    client.on 'data', (t)->
      t = JSON.parse(t).execute
      t.time = new Date(t.time)
      t.name.should.equal opts.name
      t.time.getTime().should.equal opts.time.getTime()
      client.end()

    client.on 'close', ->
      done()

    t = new Task(opts)
    server.scheduler.queue.enq(t)
    server.start()

  afterEach (done)->
    server._close().then ->
      done()

  after (done)->
    mongoose.connection.close ->
      done()
