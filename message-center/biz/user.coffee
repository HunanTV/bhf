async = require 'async'
_ = require 'lodash'

md5 = require 'MD5'

Base = require('water-pit').Base

bean = require '../bean/user'

Log = require '../log'

class User extends Base
  constructor: ->

  ###
    注册用户
  ###
  post: (req, resp, next)->
    self = @
    user = req.body
    #参数不正确，表单有误
    return @code406(resp) if not @verify(user)

    username = user.username

    queue = []

    #查看用户名是否已经注册
    queue.push((done)->
      bean.isExistUser(username).then((count)->
        done(null, count)
      ).catch((error)->
        Log.error(error)
        done(500)
      )
    )

    #判断处理
    queue.push((count, done)->
      if count
        return done(205)
      done(null)
    )

    #保存用户
    queue.push((done)->
      user = self.format(user)
      bean.save(user).then((data)->
        done(null, data)
      ).catch((error)->
        Log.error(error)
        done(500)
      )
    )

    async.waterfall(queue, (error, user)->
      return resp.send(user)  if not error

      switch error
        when 500 then return self.code500(resp) #服务器出错
        when 205 then return self.code205(resp) #用户名重复
        else self.code503(resp) #未知错误

    )

  ###
    校验提交的信息是否合法
  ###
  verify: (user)->
    return false if not user
    return false if not _.trim(user.username)
    return false if not _.trim(user.password)
    return false if user.password isnt user.password_repeat
    true


  format: (user)->
    def =
      username: ""
      password: ""
      email: ""

    for key, value of def
      def[key] = user[key]

    def.password = md5(def.password)

    def

module.exports = new User()