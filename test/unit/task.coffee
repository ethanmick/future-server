#
#
#
should = require('chai').should()
Task = require '../../lib/models/task'

describe 'Task', ->

  it 'should exist', ->
    should.exist Task

  it 'should not have occured', ->
    date = new Date()
    date.setMinutes(date.getMinutes() + 3)
    t = new Task(time: date)
    t.hasOccured().should.be.false

  it 'should have occured', ->
    date = new Date()
    date.setMinutes(date.getMinutes() - 1)
    t = new Task(time: date)
    t.hasOccured().should.be.true
