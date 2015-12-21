_entity = require '../entity/log'
_commom = require '../common'
_ = require 'lodash'
_async = require 'async'
_http = require('bijou').http

#写入日志
exports.writeLog = (member_id, type, target_id, content)->
  data =
    member_id: member_id
    type: type
    target_id: target_id
    content: content
    timestamp: new Date().getTime()

  _entity.save data, ->

exports.getLogWithIssue = (client, cb)->
  target_id = client.params.issue_id
  exports.getLog 'issue', target_id, cb

#根据类型和target_id获取log
exports.getLog = (type, target_id, cb)->
  pagination = _entity.pagination 1, 10
  _entity.fetch type, target_id, pagination, cb