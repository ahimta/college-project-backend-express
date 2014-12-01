express = require('express')
config  = require('config')
router  = express.Router()

assertSupervisor = require('./concerns/middleware/authentication').assertSupervisor
TeacherAccount   = require (config.get('paths.models') + '/teacher_account')
simpleCrud       = require('./concerns/shared_controllers/simple_crud')
validator        = require('./concerns/middleware/validators').teacherAccount

constructor = require(config.get('paths.constructors')).teacherAccount
serializer  = require(config.get('paths.serializers')).teacherAccount

module.exports = (app) ->
  app.use('/api/v0/teacher_accounts', router)

simpleCrud(router, TeacherAccount, 'teacher_accounts', serializer, constructor)
  .destroy(assertSupervisor)
  .create([assertSupervisor, validator])
  .update([assertSupervisor, validator])
  .index(assertSupervisor)
  .show(assertSupervisor)