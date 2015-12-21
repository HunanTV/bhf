redisClient = require('../db-connect').redis_conn()
async = require 'async'
jpush = require 'jpush-sdk'
_Slave = require './slave'

Log = require '../log'
config = require('../config')

_client = jpush.buildClient(config.jpush.appKey, config.jpush.masterKey)

class JPusherSlave extends _Slave
  constructor: (@event)->
    @type = "jpusher"
    @key = config.message.jpusher
    @initCall()

  send: (data, done)->
    self = @
    msg = data.msg
    device_id = msg.device_id
    device_type = msg.device_type
    message = msg.message
    data = msg.data

    _client.push().setPlatform(jpush.ALL)
      .setAudience(jpush.registration_id(device_id))
      .setNotification('Hi, BHF', jpush.ios(message, '', 1, false, data))
      .send((err, res)->
        self.dealErrorMessage(data) if err
        done(null, msg)
      )

module.exports = JPusherSlave