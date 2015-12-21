Base = require './base'
#获取黑砖窑里面的包工头
Supervisor = require '../black-brickkiln/supervisor'
#用来发邮件的奴隶数量
slaveCount = 3

class Email extends Base
  constructor: (@key)->
    #召唤处一个包工头 包含slaveCount个奴隶的
    @supervisor  = new Supervisor("email", slaveCount)

  #检验消息体
  verify: (message)-> return true


key = require('../config').message.email

module.exports = new Email(key)