###
  项目
###
_entity = require '../entity'
_common = require '../common'
_ = require 'lodash'
_async = require 'async'
_http = require('bijou').http
_notifier = require '../notification'
_guard = require './guard'
_moment = require 'moment'
_uuid = require 'node-uuid'

#添加邀请
exports.post = (client, cb)->
  project_id = client.params.project_id
  queue = []

  #检查权限
  queue.push(
    (done)->
      _guard.projectPermission project_id, client.member, '*', (err)-> done err
  )

  #检查用户的邀请码是否太多
  queue.push(
    (done)->
      cond = creator: client.member.member_id, status: 'new'
      _entity.invite.count cond, (err, total)->
        return done err if err
        err = _http.notAcceptableError('您有太多未使用的邀请码') if total >= 5
        done err
  )

  queue.push(
    (done)->
      data =
        project_id: project_id
        expire: _moment().add(1, 'years').valueOf()
        creator: client.member.member_id
        status: 'new'
        token: _uuid.v4().replace /\-/g, ''
        timestamp: new Date().getTime()

      _entity.invite.save data, done
  )

  _async.waterfall queue, (err, id)->
    result = id: id
    cb err, result

exports.get = (client, cb)->
  cond = creator: client.member.member_id, status: 'new'
  _entity.invite.find cond, cb