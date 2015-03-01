'use strict'
#
#
#
#
Q = require 'q'
Scheduler = require '../../lib/models/scheduler'
Task = require '../../lib/models/task'
sinon = require 'sinon'

describe 'Scheduler', ->

  s = null
  beforeEach ->
    s = new Scheduler()

  it 'should emit an event when it has a task', (done)->
    fake = hasOccured: -> yes
    s.queue.enq(fake)
    s.start()

    s.on 'task', (t)->
      done()

  it 'should enqueue new tasks', (done)->
    f1 = hasOccured: -> no
    f2 = hasOccured: -> no
    stub = sinon.stub(Task, 'soon').returns Q([f1, f2])
    s.readDB()
    setTimeout ->
      s.queue.size().should.equal 2
      stub.restore()
      done()
    , 100
