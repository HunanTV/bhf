wego = require 'wego-enterprise'
config = require('../config')

async = require 'async'

accessToken = new wego.AccessToken(config.weixin.corpid, config.weixin.corpsecret)
_member = new wego.Member("", config.weixin.agentid)

setMemberToken = ->
  accessToken.get((error, token)->
    return _member.setToken(token) if not error
    console.log error
  )

setMemberToken()

class WeixinMember
  constructor: ->

  create: (member, cb)->
    _member.create(member, (error, statuscode, body)->
      return cb(null) if statuscode is 200
      setMemberToken() if statuscode is 403
      console.log statuscode
      console.error error if error
      console.log body
      cb("创建失败")
    )

  update: (member, cb)->
    _member.update(member, (error, statusCode, body)->
      return cb(null) if statusCode is 200
      setMemberToken() if statusCode is 403
      console.error error if error
      console.log body
      cb("更新失败")
    )

module.exports = new WeixinMember()
