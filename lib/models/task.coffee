'use strict'
#
#
#
#
mongoose = require('mongoose-q')()
Schema = mongoose.Schema

Task = new Schema
  name:
    type: String
    unique: yes
  time:
    type: Date
    required: yes
  opts:
    type: Schema.Types.Mixed
    default: {}
  updated_at:
    type: Date
    default: Date.now
  created_at:
    type: Date
    default: Date.now

Task.methods =

  hasOccured: (lag = 0)->
    d = new Date()
    d.setMilliseconds(d.getMilliseconds() - lag)
    @time < d

Task.statics =

  soon: (future = 3)->
    date = new Date()
    date.setMinutes(date.getMinutes() + future)
    @findQ
      time:
        $lte: date

module.exports = mongoose.model 'Task', Task
