redisClient = require('../db-connect').redis_conn()
async = require 'async'
Log = require '../log'
_Slave = require './slave'

config = require '../config'

_key = config.message.weixin

Wego = require('wego-enterprise')

Message = Wego.Message
access_token = new Wego.AccessToken(config.weixin.corpid, config.weixin.corpsecret)

weixin_token = ""

getToken = (cb)->
  access_token.get((error, token)->
    return Log.error(error) if error
    weixin_token = token
    cb and cb(token)
  )

class WeixinSlave extends _Slave
  constructor: (@event)->
    @message = new Message(weixin_token, config.weixin.agentid)
    @type = "weixin"
    @key = _key
    @initCall()

  send: (data, done)->
    self = @
    msg = data.msg
    @message.sendText(msg.touser, msg.content, (error, statusCode)->
      done(null, msg)
      return if statusCode is 200
      self.dealErrorMessage(data)
      self.setToken() if statusCode is 403 #or statusCode is 400
    )

  setToken: ->
    self = @
    getToken((token)->
      self.message.setToken(token)
    )

module.exports = WeixinSlave