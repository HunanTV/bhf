###
  成员
###

_util = require 'util'
_bijou = require('bijou')
_BaseEntity = _bijou.BaseEntity
_http = _bijou.http
_common = require '../common'

class Member extends _BaseEntity
  constructor: ()->
    super require('../schema/member').schema

  #检查用户是否已经存在
  memberExists: (username, cb)->
    @exists username: username, cb

  #根据帐号查找用户信息
  findMemberByAccount: (account, cb)->
    options =
      beforeQuery: (query)->
        query.where ()->
          @orWhere('email', account).orWhere('username', account)
    @findOne null, options, cb


  #登录
  signIn: (account, password, cb)->
    errMessage = "用户名或者密码错误"

    @findMemberByAccount account, (err, member)->
      return cb err if err
      #没有这个用户名
      return cb _http.notAcceptableError(errMessage) if not member
      #检查密码是否匹配
#      console.log member.password,  _common.md5(password)
      return cb _http.notAcceptableError(errMessage) if member.password isnt _common.md5(password)

      cb null, member

#  #用户注册
#  signUp: (data, cb)->
#    self = @;
#    @memberExists data.username, (err, exists)->
#      return cb _http.notAcceptableError("用户名#{data.username}已经存在，请选择其它用户名") if exists
#
#      data.password = _common.md5 data.password
#      self.save data, cb

module.exports = new Member
