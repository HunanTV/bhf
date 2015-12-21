express = require('express')

uuid = require 'uuid'

messageStack = require './message-stack'

router = express.Router()

_global = require './global'

class Router
  constructor: (@io)->
    @initRouter()

  get: -> router

  handle: (req, resp)->
    #当当前没有客户端连接时，直接拒绝响应
    if _global.client_count < 1
      return resp.status(404).end()

    copyPropertyArray = ["body", "originalUrl", "headers", "method"]
    id = uuid.v1()
    messageStack.push(id, (statusCode, headers, data)->
      delete headers["content-length"] if headers
      resp.set(headers)
      resp.status(statusCode).end(data)
    )
    data = {}
    data[item] = req[item] for item in copyPropertyArray
    @io.emit('api', id, data)

  initRouter: ->
    self = @
    router.all("/api/*", (req, resp, next)-> self.handle(req,  resp))

module.exports = (io)-> new Router(io)
