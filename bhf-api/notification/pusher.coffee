#    Author: 易晓峰
#    E-mail: wvv8oo@gmail.com
#    Date: 6/1/15 3:05 PM
#    Description: 负责向客户端推送
_ = require 'lodash'
_common = require '../common'
_entity = require '../entity'

_jpusher = require('notification-center-sdk').mobilPusher


#发起推送信息
exports.push = (device_id, device_type, message, data)->
  return console.log("推送功能禁止") if not _common.config.notification.client

  _jpusher(device_id, device_type, message,  data, (error, statuscode)->
    console.log("推送失败") if error or statuscode isnt 200
  )


#向用户推送消息
exports.postToMember = (member_id, message, data)->
  cond = member_id: member_id
  _entity.member_device.find cond, (err, result)->
    return if err or result.length is 0
    _.map result, (current)->
      exports.push current.device_id, current.device_type, message, data