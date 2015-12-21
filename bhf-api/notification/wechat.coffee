#    Author: 易晓峰
#    E-mail: wvv8oo@gmail.com
#    Date: 6/19/15 10:24 AM
#    Description: 微信推送的接口
_wechatSDK = require('notification-center-sdk').weixin
_common = require '../common'

#添加推送任务，这里可以检测用户是否开启推送，如果没有开启
exports.addTask = (sender, receiver, message, extra)->
  return console.log("微信通知禁止") if not _common.config.notification.weixin
  #用户可能没有设置微信号
  return if not receiver?.weixin
  console.log "发微信-> #{receiver.weixin}"
  _wechatSDK(receiver.weixin, message)
