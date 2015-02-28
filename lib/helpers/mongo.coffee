'use strict'
#
#
#
#
Q = require 'q'
mongoose = require('mongoose-q')()

module.exports = ->
  deferred = Q.defer()
  mongoose.connect('mongodb://localhost/future_development')
  db = mongoose.connection

  db.on 'error', (err)->
    deferred.reject(err)

  db.once 'open', ->
    deferred.resolve(db)

  deferred.promise
