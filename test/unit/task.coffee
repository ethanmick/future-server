#
#
#
should = require('chai').should()
Task = require '../../lib/models/task'

describe 'Task', ->

  it 'should exist', ->
    should.exist Task
