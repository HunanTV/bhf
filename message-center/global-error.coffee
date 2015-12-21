Log = require './log'

global.uncatchError = {
  redis: 1
  mysql: 1
}

module.exports = {
  ###
    设置Redis的服务器状态
  ###
  redisStoped: ->
    global.uncatchError.redis =  0

  redisRecover: ->
    global.uncatchError.redis = 1

  everythingIsOk: ->
    return false for key, value of global.uncatchError when value is 0
    return true
}