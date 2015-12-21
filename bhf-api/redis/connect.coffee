#    Author: 易晓峰
#    E-mail: wvv8oo@gmail.com
#    Date: 6/8/15 11:43 AM
#    Description: redis的基础类

_redis = require 'redis'
_common = require '../common'
_config = _common.config
_client = null

(->
  cfg = _common.config.redis
  exports.redis = _client = _redis.createClient(cfg.port, cfg.server)
)()