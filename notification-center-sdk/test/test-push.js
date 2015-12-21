(function() {
  var mobilPusher;

  mobilPusher = require('../index').mobilPusher;

  describe("消息通知", function() {
    return it("手机推送", function(done) {
      return mobilPusher("061e3470869", "ios", "hello world", {
        a: 1
      }, function(error, statuscode) {
        console.log(error, statuscode);
        return done();
      });
    });
  });

}).call(this);
