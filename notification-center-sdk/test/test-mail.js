(function() {
  var email;

  email = require('../index').email;

  describe("消息通知", function() {
    return it("发邮件", function(done) {
      return email("test message SDK", "646344359@qq.com", "hello world", function(error, statuscode) {
        console.log(error, statuscode);
        return done();
      });
    });
  });

}).call(this);
