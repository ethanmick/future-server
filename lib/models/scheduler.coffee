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
Task = require './task'

class Scheduler extends EventEmitter

  constructor: ->
    super()
    @queue = new PriorityQueue (a, b)->
      b.time - a.time

  start: ->
    @timer = setInterval(@tick.bind(this), _100_MILLISECONDS)
    @dbTimer = setInterval(@readDB.bind(this), _3_MINUTES)

  tick: ->
    log.info 'ticking...'
    unless @queue.isEmpty()
      while not @queue.isEmpty() and @queue.peek().hasOccured(50)
        task = @queue.deq()
        @emit 'task', task

  readDB: ->
    log.info 'reading db...'
    Task.soon().then (tasks)=>
      @queue.enq(t) for t in tasks

  stop: ->
    clearInterval(@timer)
    @timer = null


module.exports = Scheduler
