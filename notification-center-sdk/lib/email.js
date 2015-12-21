(function() {
  var config, request;

  request = require('request');

  config = require('../config');


  /*
    发送邮件消息
    @params {string} 标题
    @params {string} 收件人
    @params {function} 邮件内容
      接收两个参数: error和statuscode
      statuscode 为200时表示消息服务器已经接受了消息体，准备发送
                为406时，表示参数错误。
   */

  module.exports = function(subject, mailTo, content, callback) {
    return request.post({
      url: config.url + "/api/message/email",
      headers: {
        private_token: config.token
      },
      formData: {
        to: mailTo,
        subject: subject,
        html: content
      }
    }, function(error, resp, body) {
      return callback && callback(error, resp.statusCode);
    });
  };

}).call(this);
