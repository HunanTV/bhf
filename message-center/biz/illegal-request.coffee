###
  非法请求过滤
  操作日志 记录
###
_ = require 'lodash'

pathToRegexp = require('path-to-regexp')

config = require '../config'

isDev = config.develop

redisClient = require('../db-connect').redis_conn()

LogBean = require '../bean/log'

Log = require '../log'

router = require('../router')

baseUrl = router.baseUrl
no_authentication = router.no_authentication

#是否为免验证接口
isNoAuthenticationPath = (path, method)->
  for item in no_authentication
    #根据配置路径生成路径解析器
    reg = pathToRegexp("#{baseUrl}#{item.path}", [])
    #根据解析器和参数解析原始路径
    continue if not reg.test(path)
    #如果没有设置methods表示该路径下所有方法都不用验证
    return true if not item.methods
    #如果method在配置里面则不需要验证，否则需要验证
    return true if _.indexOf(item.methods, method) isnt -1
    return false

  return false

#是否为验证用户
isAuthenticationUser = (token, cb)-> redisClient.get(token, (error, uid)->
  cb(error, uid)
)

module.exports = (req, resp, next)->
  # 开发环境
  return next() if isDev

  # 免验证的api接口
  return next() if isNoAuthenticationPath(req.path, req.method)

  if req.headers.private_token is config.admin_token
    LogBean.save({
      uid: "admin"
      api: req.url
      body: JSON.stringify(req.body)
    }).then(()->)
    return next()

  #保存操作日志
  isAuthenticationUser(req.headers.private_token, (error, uid)->
    if error
      Log.error(error)
      return resp.status(503)

    if uid
      LogBean.save({
        uid: uid
        api: req.url
        body: JSON.stringify(req.body)
      }).then(()->)
      return next()

    #拒绝操作
    resp.status(403).end()

  )


