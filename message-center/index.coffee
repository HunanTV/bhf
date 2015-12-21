_path = require 'path'
_config = require './config'
_bodyParser = require 'body-parser'
_multer = require 'multer'

_Waterpit = require('water-pit').Waterpit
#路由映射
_RouterMap = require('./router')
_illeageRequest = require './biz/illegal-request'

express = require 'express'
express_session = require 'express-session'

globalError = require './global-error'

app = express()

app.use express_session({ secret: 'game-path-v1.0', cookie: { maxAge: 1000 * 60 * 60 * 24 }})
app.use _bodyParser.json()
app.use _bodyParser.urlencoded extended: true
app.use _multer()

router = express.Router()

new _Waterpit(router, _RouterMap)

###
  保证静态页面服务可用
###
app.all "/api/*", (req, resp, next)->
  return next() if globalError.everythingIsOk()
  resp.send("<h1>503！ 暂停服务！ 请联系客服！</h1>")

###
  非法请求拦截
###
app.all "/api/*", _illeageRequest

app.use '/', router

app.listen _config.port