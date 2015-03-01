'use strict'
#
#
#
#
Scheduler = require '../../lib/models/scheduler'
sinon = require 'sinon'

describe 'Scheduler', ->

  s = null
  beforeEach ->
    s = new Scheduler()

  it 'should tick', (done)->
    done()
