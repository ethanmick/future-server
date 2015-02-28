#
# Ethan Mick
# 2015
#

log = require './lib/helpers/log'
mongoose = require('mongoose-q')()
net = require 'net'

log.debug 'woot'


server = net.createServer (c)->
  log.warn 'Client connected'

  c.on 'end', ->
    log.warn 'client disconnected'

server.listen 8124, ->
  log.warn 'server bound'
