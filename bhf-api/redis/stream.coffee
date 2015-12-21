#    Author: 易晓峰
#    E-mail: wvv8oo@gmail.com
#    Date: 6/8/15 11:48 AM
#    Description: 用户的活动
_async = require 'async'
_ = require 'lodash'

_common = require '../common'
_connect = require './connect'
_config = _common.config

#获取成员活动的key
getKey = (member_id)->
  "#{_config.redis.unique}:member_stream:#{member_id}"

#添加活动
exports.append = (sender, receiver, eventName, data, cb)->
  return if not (sender and receiver)

  key  = getKey receiver.id
  redis = _connect.redis
  activity =
    eventName: eventName
    data: data
    sender_id: sender.id
    sender: sender.realname
    timestamp: new Date().valueOf()

  #每个用户只保存99条活动
  redis.lpush key, JSON.stringify(activity), (err)->
    redis.ltrim key, 0, 1000, (err)-> cb? null

#根据用户的ID来获取工作流
exports.getStream = (member_id, cb)->
  key  = getKey member_id
  redis = _connect.redis
  redis.lrange key, 0, 99, (err, result)->
    result = _.map result, (current)-> JSON.parse(current)
    cb err, result