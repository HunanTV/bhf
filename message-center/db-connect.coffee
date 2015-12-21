_Coal = require 'coal'
_config = require('./config')
Log = require './log'
globalError = require './global-error'

###
  mysql 数据库连接
###

_coal = new _Coal(_config.db, _config.develop)

###
  redis 数据库连接
###

redis_config = _config.redis

redis = require 'redis'

client = redis.createClient(redis_config.port, redis_config.host)

client.on("error", (error)->
  Log.error(error)
  globalError.redisStoped()
)

client.on("ready", ()->
  globalError.redisRecover()
)

exports.conn = -> _coal
exports.redis_conn = -> client