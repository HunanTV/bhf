redisClient = require('../db-connect').redis_conn()
class Base
  constructor: ->

  push: ->

  pack: (msg, count = 0)->
    data =
      msg: msg
      count: count

  #带继承体重写该该函数
  verify: -> true

  push: (message, cb)->
    #消息校验未通过
    return cb(406,  "参数不合法") if not @verify(message)
    #同过后给出正在处理消息
    cb(200)
    data = @pack(message)
    redisClient.lpush(@key, JSON.stringify(data))
    @supervisor.startWork()

module.exports = Base