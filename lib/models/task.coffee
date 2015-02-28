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
  options:
    type: Schema.Types.Mixed
    default: {}
  updated_at:
    type: Date
    default: Date.now
  created_at:
    type: Date
    default: Date.now

module.exports = mongoose.model 'Task', Task
