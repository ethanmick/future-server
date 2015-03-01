'use strict'
#
# Ethan Mick
# 2015
#
#
EventEmitter = require('events').EventEmitter
PriorityQueue = require 'priorityqueuejs'
_100_MILLISECONDS = 100
_3_MINUTES = 180000
log = require '../helpers/log'

class Scheduler extends EventEmitter

  constructor: ->
    super()
    @queue = new PriorityQueue (a, b)->
      b.time - a.time

    @timer = setInterval(@tick.bind(this), _100_MILLISECONDS)
    @dbTimer = setInterval(@readDB.bind(this), _3_MINUTES)

  tick: ->
    log.info 'ticking...'
    unless @queue.isEmpty()
      task = @queue.peek
      return unless task.hasOccured(50)
      # Task has occured and has to be fired off

  readDB: ->
    log.info 'reading db...'
    Task.soon().then (tasks)=>
      @queue.enq(t) for t in tasks

  stop: ->
    clearInterval(@timer)
    @timer = null


module.exports = Scheduler
