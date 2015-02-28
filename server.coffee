'use strict'
#
# Ethan Mick
# 2015
#
Q = require 'q'
mongoose = require('mongoose-q')()
log = require './lib/helpers/log'
Server = require './lib/models/server'

ConnectMongo = ->
  deferred = Q.defer()
  mongoose.connect('mongodb://localhost/future_development')
  db = mongoose.connection

  db.on 'error', (err)->
    deferred.reject(err)

  db.once 'open', ->
    deferred.resolve(db)

  deferred.promise

server = new Server()
ConnectMongo().then ->
  server._listen(8124)
.then ->
  log.warn 'Future has started.'
.fail(log.error)
.done()
