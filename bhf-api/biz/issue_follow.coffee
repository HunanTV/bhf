_entity = require '../entity'
_commom = require '../common'
_ = require 'lodash'
_async = require 'async'
_http = require('bijou').http
_guard = require './guard'


exports.get = (client, cb)->
  _entity.issue_follow.getFollowList client.params.issue_id,(err, result)->
  	cb err, result


exports.save = (client, cb)->
  data =
    issue_id: client.params.issue_id
    member_id: client.member.member_id

  data.member_id = client.body.member_id if client.body.member_id

  queue = []

  #检测是否存在关注关系
  queue.push(
    (done)->
      _entity.issue_follow.exists data, (err, exists)->
        return done err if err
        err = _http.notAcceptableError('已经关注过了') if exists
        done err
  )

  queue.push(
    (done)->
      _entity.issue_follow.save data,(err,result)->
        cb err, result
  )

  _async.waterfall queue, cb



exports.delete = (client, cb)->
  data =
  	issue_id: client.params.issue_id
  data.member_id = client.query.id if client.query.id

  _entity.issue_follow.remove data,(err,result)->
  	cb err, result




# exports.getIssues = (client, cb)->
#   data = 
#     member_id: client.member.member_id
#   data.project_id = client.params.project_id if client.params.params isnt "all"

#   _entity.issue_follow.getIssueList data, (err, result)->
#     cb err, result









