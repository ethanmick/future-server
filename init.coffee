'use strict'
#
# Ethan Mick
# 2015
#
Q = require 'q'
mongoose = require('mongoose-q')()
log = require './lib/helpers/log'
Server = require './lib/server'
mongo = require './lib/helpers/mongo'

server = new Server(port: 8124)
mongo().then ->
  server.start()
.then ->
  server.routes()
.then ->
  log.warn 'Future has started.'
.fail(log.error)
.done()
