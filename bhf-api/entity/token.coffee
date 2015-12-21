_common = require '../common'
_config = _common.config
_uuid = require 'uuid'
_async = require 'async'
_redis = require 'redis'
_client = null

HASHTOKENKEY = "#{_config.redis.unique}:token:key"
HASHKEY = "#{_config.redis.unique}:token"

(->
  cfg = _common.config.redis
  _client = _redis.createClient(cfg.port, cfg.server)
)()


#获取保存token的key，这个key是用于查找token用的，比如说要删除某个用户的tokey，先用这个key找到token，然后删除token
getTokenKey = (member_id)-> "member:#{member_id}"

#请求token
exports.requestToken = (member_id, role, cb)->
  uuid = _uuid.v4()
  queue = []
  #如果现有的token存在，则删除
  queue.push(
    (done)-> removeToken member_id, done
  )

  #添加新的token，并保存到key中
  queue.push(
    (done)->
      #保存token到key中，这个key主要用于删除时查找用户的tokey
      _client.hset HASHTOKENKEY, getTokenKey(member_id), uuid, done
  )

  #保存token对应的member_id
  queue.push(
    (done)->
      member =
        id: member_id
        role: role


      _client.hset HASHKEY, uuid, JSON.stringify(member), done
  )

  _async.series queue, (err)-> cb err, uuid

#删除一个用户的tokey（可能并不知道token）
removeToken = exports.removeToken = (member_id, cb)->
  queue = []
  queue.push(
    (done)->
      #查找与用户id对应的token
      _client.hget HASHTOKENKEY, getTokenKey(member_id), done
  )

  queue.push(
    (uuid, done)->
      if typeof uuid is 'function'
        uuid = null
        done = uuid

      return done null if not uuid
      #删除uuid对应的用户id
      _client.hdel HASHKEY, uuid, (err)-> done err
  )

  #删除
  queue.push(
    (done)->
      _client.hdel HASHTOKENKEY, getTokenKey(member_id), (err)->
        done err
  )

  _async.waterfall queue, cb


#根据token，查找对应的用户id
exports.findMemberId = (token, cb)->
  _client.hget HASHKEY, token, (err, data)->
    return cb err if err or not data
    try
      cb null, JSON.parse(data)
    catch e
      cb null