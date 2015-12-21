Base = require('water-pit').Base
path = require 'path'

redisClient = require('../db-connect')

fs = require 'fs'

dispatcherPath = path.join(process.cwd(), "dispatcher")

class Message extends Base
  constructor: ->

  post: (req, resp, next)->

    type = req.params.type

    type = "unknow" if not type

    return @code406(resp, "路径访问错误") if (not @isExistsDispatcher(type)) or type is "base"

    #请求相关类型的处理消息工具
    require(path.join(dispatcherPath, type)).push(req.body, (statusCode, content)->
      resp.status(statusCode).send(content or "")
    )


  get: (req, resp, next)->

    resp.sendStatus(200)

  isExistsDispatcher: (type)->
    return true if fs.existsSync(path.join(dispatcherPath, "#{type}.js"))
    return true if fs.existsSync(path.join(dispatcherPath, "#{type}.coffee"))
    return false

module.exports = new Message()