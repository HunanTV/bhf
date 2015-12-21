(function() {
  var weixin;

  weixin = require('../index').weixin;

  describe("消息通知", function() {
    return it("发微信", function(done) {
      return weixin("huyinghuan", "Message SDK test", function(error, statuscode) {
        console.log(error, statuscode);
        return done();
      });
    });
  });

}).call(this);
