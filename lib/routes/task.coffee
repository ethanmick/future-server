#
# Ethan Mick
# 2015
#

create = (req, reply)->
  task = new Task(req.payload)
  task.saveQ().then ->
    reply({name: task.name})
  .done()

get = (req, reply)->
  Task.findOneQ(name: req.params.id).then (task)->
    reply(error: 'Not Found!') unless task
    reply(task: task.toObject())
  .done()

del = (req, reply)->
  name = req.param.id
  Task.removeQ(name: name).then ->
    reply(deleted: name)
  .done()

module.exports = [
  {
    method: 'POST'
    url: '/v1/task'
    handler: create
  }
  {
    method: 'GET'
    url: '/v1/task/{id}'
    handler: get
  }
  {
    method: 'DELETE'
    url: '/v1/task/{id}'
    handler: del
  }
]
