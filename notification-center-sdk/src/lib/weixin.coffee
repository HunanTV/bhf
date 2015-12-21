config = require('../config')
request = require 'request'

###
  发送微信消息
  @params {string} 用户id, 多个用户请用 | 分割开来
  @params {string} 消息内容
  @params {function} 回调函数
    接收两个参数: error和statuscode
    statuscode 为200时表示消息服务器已经接受了消息体，准备发送
              为406时，表示参数错误。
###
module.exports = (userId, content, callback)->
  request.post(
    {
      url: "#{config.url}/api/message/weixin",
      headers: {private_token: config.token}
      formData: {touser: userId, content: content}
    },
    (error, resp, body)->
      callback and callback(error, resp.statusCode)
  )
