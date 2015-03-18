#
# Ethan Mick
# 2015
#
Task = require '../models/task'

create = (req, reply)->
  task = new Task(req.payload)
  task.saveQ().then ->
    reply(name: task.name)
  .done()

get = (req, reply)->
  Task.findOneQ(name: req.params.id).then (task)->
    return reply(error: 'Not Found!') unless task
    reply(task.toObject())
  .done()

del = (req, reply)->
  name = req.params.id
  Task.removeQ(name: name).then ->
    reply(deleted: name)
  .done()

module.exports = [
  {
    method: 'POST'
    path: '/v1/task'
    handler: create
  }
  {
    method: 'GET'
    path: '/v1/task/{id}'
    handler: get
  }
  {
    method: 'DELETE'
    path: '/v1/task/{id}'
    handler: del
  }
]
