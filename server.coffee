#
# Ethan Mick
# 2015
#
Q = require 'q'
net = require 'net'
mongoose = require('mongoose-q')()
log = require './lib/helpers/log'

server = net.createServer (c)->
  log.warn 'Client connected'

  c.on 'end', ->
    log.warn 'client disconnected'

ConnectMongo = ->
  deferred = Q.defer()
  mongoose.connect('mongodb://localhost/future_development')
  db = mongoose.connection

  db.on 'error', (err)->
    deferred.reject(err)

  db.once 'open', ->
    deferred.resolve(db)

  deferred.promise

listen = Q.nbind(server.listen, server)

ConnectMongo().then ->
  listen(8124)
.then ->
  log.warn 'Future has started.'
.fail(console.log)
.done()
