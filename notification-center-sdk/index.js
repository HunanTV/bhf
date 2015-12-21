(function() {
  module.exports = {
    WeixinMember: require('./lib/weixin-member'),
    mobilPusher: require('./lib/mobile-push'),
    email: require('./lib/email'),
    webhook: require('./lib/webhook'),
    weixin: require('./lib/weixin')
  };

}).call(this);
