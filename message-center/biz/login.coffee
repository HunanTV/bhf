_ = require 'lodash'
async = require 'async'
_uuid = require 'uuid'
md5 = require 'MD5'

Base = require('water-pit').Base
_user = require '../bean/user'
Log = require '../log'

redisClient = require('../db-connect').redis_conn()

class Login extends Base
  constructor: ->

  getToken: (req, resp, next)->
    user = req.body
    return @code401 if not _.trim(user.username) or not _.trim(user.password)
    self = @
    queue = []
    #根据帐号密码获取 用户信息
    queue.push((done)->
      _user.getByUsernameAndPassword(user.username, md5(user.password)).then((result)->
        return done(401) if not result
        done(null, result)
      ).catch((error)->
        Log.error(error)
        done(500)
      )
    )

    #判断用户是否合法
    queue.push((user, done)->
      #用户状态不为1 表示该账户已经被 删除或者注销 处于不可用状态
      return done(403) if user.status isnt 1
      done(null, user)
    )

    #查找id关联token, 并删除
    queue.push((user, done)->
      id = user.id
      redisClient.get(id, (error, token)->
        if error
          Log.error(error)
          return done(500)

        done(null, user, token)
      )
    )

    #删除旧token
    queue.push((user, token, done)->
      redisClient.del(token, (error)->
        if error
          Log.error(error)
          return done(500)
        done(null, user)
      )
    )

    #生成新的token
    queue.push((user, done)->
      token = _uuid.v1()
      redisClient.mset(user.id, token, token, user.id, (error)->
        if error
          Log.error(error)
          return done(500)
        done(null, user, token)
      )
    )

    #登录操作流程完成
    actionfinish = (error, user, token)->
      if not error
        return resp.status(200).send({private_token: token})

      switch error
        when 401 then self.code401(resp, "用户名或密码错误")
        when 403 then self.code403(resp, "该用户已被禁用， 请联系管理员恢复")
        when 500 then self.code500(resp)
        else self.code503(resp)

    async.waterfall(queue, actionfinish)

  simpleUserInfo: (user)->
    info = {
      username: null,
      name: null #真实姓名
      email: null #email
      phone: null #手机
    }
    for key, value of  info
      info[key] = user[key]
    info

  b: (req, resp, next)-> resp.send("2")

module.exports = new Login()