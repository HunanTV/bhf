redisClient = require('../db-connect').redis_conn()
async = require 'async'

Log = require '../log'
config = require('../config')

request = require 'request'

_Slave = require './slave'

class WebhooksSlave extends _Slave
  constructor: (@event)->
    @key = config.message.webhooks
    @type = "webhooks"
    @initCall()

  send: (data, done)->
    self = @
    msg = data.msg
    headers = msg.headers

    option =
      url: msg.url
      body: msg.body
      json: true

    option.headers = msg.headers if headers

    request.post(option, (error, resp, body)->
      self.dealErrorMessage(data) if error
      if resp.statusCode isnt 200
        Log.error(body)
    )

    done(null, msg)

module.exports = WebhooksSlave