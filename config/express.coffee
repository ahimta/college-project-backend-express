express = require 'express'
path    = require 'path'
fs      = require 'fs'

cookieParser   = require 'cookie-parser'
bodyParser     = require 'body-parser'
compress       = require 'compression'
logger         = require 'morgan'

module.exports = (app, config) ->

  app.use logger('dev')
  app.use bodyParser.json()
  app.use cookieParser()
  app.use compress()
  app.use express.static(config.root + '/public')

  controllersPath = path.join __dirname, '../app/controllers'
  fs.readdirSync(controllersPath).forEach (file) ->
    if file.indexOf('.coffee') >= 0
      require(controllersPath + '/' + file)(app)

  # catch 404 and forward to error handler
  app.use (req, res, next) ->
    err        = new Error('Not Found')
    err.status = 404
    next(err)

  # error handlers
  app.use (err, req, res, next) ->
    res.status(err.status || 500)
    next(err)

  # development error handler
  # will print stacktrace
  if app.get('env') == 'development'
    app.use (err, req, res, next) ->
      res.send(message: err.message, status: err.status, stack: err.stack)

  # production error handler
  # no stacktraces leaked to user
  app.use (err, req, res, next) ->
    res.send(message: err.message, status: err.status)