(function() {
  var config, request;

  config = require('../config');

  request = require('request');


  /*
    推送消息
    @params {string} 设备id
    @params {string} 设备类型
    @params {string} 消息内容
    @params {json} 扩展数据
    @params {function} 可选
      接收两个参数: error和statuscode
      statuscode 为200时表示消息服务器已经接受了消息体，准备发送
                为406时，表示参数错误。
   */

  module.exports = function(device_id, device_type, message, data, callback) {
    return request.post({
      url: config.url + "/api/message/jpusher",
      headers: {
        private_token: config.token
      },
      body: {
        device_id: device_id,
        device_type: device_type,
        message: message,
        data: data
      },
      json: true
    }, function(error, resp, body) {
      return callback && callback(error, resp.statusCode);
    });
  };

}).call(this);
