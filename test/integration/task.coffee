'use strict'
#
#
#
should = require('chai').should()
Q = require 'q'
mongo = require '../../lib/helpers/mongo'
mongoose = require('mongoose-q')()
uuid = require 'uuid'
Task = require '../../lib/models/task'

describe 'Task Integration', ->

  before (done)->
    mongo().then ->
      Task.removeQ({})
    .then ->
      done()

  it 'should find the most recent tasks', (done)->
    date = new Date()
    date.setMinutes(date.getMinutes() + 1)

    date2 = new Date()
    date2.setMinutes(date.getMinutes() + 10)

    t = new Task(name: uuid.v4(), time: date)
    t2 = new Task(name: uuid.v4(), time: date2)
    Q.all([t.saveQ(), t2.saveQ()]).then ->
      Task.soon()
    .then (tasks)->
      tasks.should.have.length 1
      done()
    .done()


  after (done)->
    mongoose.connection.close ->
      done()
