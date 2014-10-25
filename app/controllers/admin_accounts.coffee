AdminAccount = require('mongoose').model('AdminAccount')
router       = require('express').Router()

accountValidator = require('./concerns/middleware/validators').accountValidator
assertAdmin      = require('./concerns/middleware/authentication').assertAdmin
simpleCrud       = require('./concerns/shared_controllers/simple_crud')

constructor = require('../constructors').adminAccount
serializer  = require('../serializers').adminAccount

module.exports = (app) ->
  app.use('/api/v0/admin_accounts', router)

simpleCrud(router, AdminAccount, 'admin_accounts', serializer, constructor)
  .destroy(assertAdmin)
  .create([assertAdmin, accountValidator])
  .update([assertAdmin, accountValidator])
  .index(assertAdmin)
  .show(assertAdmin)