Wego = require 'wego-enterprise'

Base = require './base'

redisClient = require('../db-connect').redis_conn()

#获取黑砖窑里面的包工头
Supervisor = require '../black-brickkiln/supervisor'

#用来发微信的奴隶数量
slaveCount = 3

class Weixin extends Base
  constructor: (@key)->
    #召唤处一个包工头 包含５个微信奴隶的
    @supervisor  = new Supervisor("weixin", slaveCount)

  #检验消息体
  verify: (message)-> return true


key = require('../config').message.weixin

module.exports = new Weixin(key)