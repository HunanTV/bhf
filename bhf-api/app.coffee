###
  入口
###
_express = require 'express.io'
_http = require 'http'
_app = _express()
_common = require './common'
_path = require 'path'
_redisStore = new require('connect-redis')(_express)
_app.http().io()

_app.configure(()->
  _app.use(_express.methodOverride())
  _app.use(_express.bodyParser(
    uploadDir: _common.config.uploadTemporary
    limit: '1024mb'
    keepExtensions: true
  ))

  _app.use(_express.cookieParser())
  _app.use(_express.session(
    secret: 'hunantv.com'
  #cookie:  maxAge: 1 * 60 * 60 * 1000
    store: new _redisStore(
      ttl: 60 * 60 * 24 * 365
      prefix: "#{_common.config.redis.unique}:session:"
      host: _common.config.redis.server
      port: _common.config.redis.port
    )
  ))
  _app.use(_express.static(__dirname + '/static'))
  _app.set 'port', process.env.PORT || _common.config.port || 8000
)

require('./initialize')(_app)

_app.listen _app.get 'port'

console.log "Port: #{_app.get 'port'}, Now: #{new Date()}"