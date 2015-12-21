
/*
  webhooks

  @params {string} webhooks的url
  @params {json} webhooks的头部
  @params {json} webhooks的post内容
  @params {function} 回调函数
  接收两个参数: error和statuscode
    statuscode 为200时表示消息服务器已经接受了消息体，准备发送
              为406时，表示参数错误。
 */

(function() {
  module.exports = function(url, header, body, callback) {
    return request.post({
      url: "http://localhost:3000/api/message/webhooks",
      headers: {
        private_token: token
      },
      body: {
        url: url,
        headers: header,
        body: body
      },
      json: true
    }, function(error, resp, body) {
      return callback && callback(error, resp.statusCode);
    });
  };

}).call(this);
