mongoose = require('mongoose')
config   = require('config')
_        = require('lodash')
Q        = require('q')

modelsPath = config.get('paths.models')

security = require('./security')

AccessToken = require(modelsPath + '/access_token')

ACCOUNTS_MODELS =
  recruiter: require(modelsPath + '/recruiter_account')
  admin: require(modelsPath + '/admin_account')


modelForRole = module.exports.modelForRole = (role) ->
  Q.Promise (resolve, reject, notify) ->
    model    = ACCOUNTS_MODELS[role]

    if model then resolve(model)
    else reject new Error('Model not found for role ' + role)


authenticate = (role, username, password) ->

  modelForRole(role)
    .then (model) ->
      model.findOne({username: username.toLowerCase()}).exec()
    .then (account) ->
      if account
        security.comparePasswords(password, account.password)
          .then (__) -> account.toObject()
      else
        throw new Error("user with username: '#{username}' not found")


module.exports.assertAccessToken = (accessToken, role=null) ->
  query           = {access_token: accessToken}
  query.user_role = role if role

  Q(AccessToken.findOne(query).exec())
    .then (tokenRecord) ->
      if tokenRecord
        modelForRole(tokenRecord.user_role).then (model) ->
          {tokenRecord: tokenRecord, accountModel: model}
      else
        throw new Error('Access token not found')
    .then (result) ->
      result.accountModel.findOne({_id: result.tokenRecord.user_id}).exec().then (accountRecord) ->
        tokenObject: result.tokenRecord.toObject()
        account: accountRecord.toObject()


module.exports.login = (role, username, password) ->

  authenticate(role, username, password)
    .then (account) ->
      security.generateSecureToken()
        .then (token) ->
          {account: account, token: token}
      .then (result) ->
        record =
          access_token: result.token
          user_role: role
          user_id: result.account._id

        AccessToken.create(record)
          .then (tokenRecord) ->
            tokenRecord: tokenRecord
            account: result.account
      .then (result) ->

        accessToken: result.tokenRecord.access_token
        account: result.account
        accountRole: role
