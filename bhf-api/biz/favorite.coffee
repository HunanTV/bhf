###
  用户收藏
###

_async = require 'async'
_ = require 'lodash'
_common = require '../common'
_entity = require '../entity'
_http = require('bijou').http

#保存用户的收藏
exports.post = (client, cb)->
  data =
    target_id: client.body.target_id
    type: client.body.type
    member_id: client.member.member_id

  if not data.target_id or data.type not in ['project', 'issue']
    return cb _http.notAcceptableError('参数非法')

  #检查是否存在，如果存在就不需要加入了
  _entity.favorite.exists data, (err, exists)->
    return cb err if err or exists

    #加入收藏
    data.timestamp = new Date().valueOf()
    _entity.favorite.save data, cb

exports.delete = (client, cb)->
  cond =
    target_id: client.query.target_id
    type: client.query.type
    member_id: client.member.member_id

  _entity.favorite.remove cond, cb
