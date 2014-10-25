mongoose = require('mongoose')
plugins  = require('./concerns/plugins')

schema = new mongoose.Schema
  specialization: {type: String, required: true}
  is_guide: {type: Boolean, default: false}
  students_ids:
    type: [mongoose.Schema.Types.ObjectId]
    ref: 'StudentAccount'
    default: []
  courses_ids:
    type: [mongoose.Schema.Types.ObjectId]
    ref: 'Course'
    default: []

schema.plugin(plugins.accountable)

module.exports = mongoose.model('TeacherAccount', schema)