###
  读取API文件，将接口列表返回到客户端
###

_fs = require 'fs-extra'
_path = require 'path'
_ = require 'lodash'
_async = require 'async'
_http = require('bijou').http
_router = require '../config/router'


exports.get = (client, cb)->
  result = []
  for item in _router
    #暂时忽略正则部分
    continue if item.path instanceof RegExp
    methods = {}
    for key, value of item.methods
      methods[key] = Boolean(value) if not value

    result.push
      url: item.path
      methods: methods

  cb null, result