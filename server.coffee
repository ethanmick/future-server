'use strict'
#
# Ethan Mick
# 2015
#
Q = require 'q'
mongoose = require('mongoose-q')()
log = require './lib/helpers/log'
Server = require './lib/models/server'
mongo = require './lib/helpers/mongo'

server = new Server()
mongo().then ->
  server._listen(8124)
.then ->
  log.warn 'Future has started.'
.fail(log.error)
.done()
