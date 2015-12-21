(function() {
  var WeixinMember, _member, accessToken, async, config, setMemberToken, wego;

  wego = require('wego-enterprise');

  config = require('../config');

  async = require('async');

  accessToken = new wego.AccessToken(config.weixin.corpid, config.weixin.corpsecret);

  _member = new wego.Member("", config.weixin.agentid);

  setMemberToken = function() {
    return accessToken.get(function(error, token) {
      if (!error) {
        return _member.setToken(token);
      }
      return console.log(error);
    });
  };

  setMemberToken();

  WeixinMember = (function() {
    function WeixinMember() {}

    WeixinMember.prototype.create = function(member, cb) {
      return _member.create(member, function(error, statuscode, body) {
        if (statuscode === 200) {
          return cb(null);
        }
        if (statuscode === 403) {
          setMemberToken();
        }
        console.log(statuscode);
        if (error) {
          console.error(error);
        }
        console.log(body);
        return cb("创建失败");
      });
    };

    WeixinMember.prototype.update = function(member, cb) {
      return _member.update(member, function(error, statusCode, body) {
        if (statusCode === 200) {
          return cb(null);
        }
        if (statusCode === 403) {
          setMemberToken();
        }
        if (error) {
          console.error(error);
        }
        console.log(body);
        return cb("更新失败");
      });
    };

    return WeixinMember;

  })();

  module.exports = new WeixinMember();

}).call(this);
