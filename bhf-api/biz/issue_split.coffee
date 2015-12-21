_ = require 'lodash'
_async = require 'async'
_http = require('bijou').http

_entity = require '../entity'
_commom = require '../common'
_guard = require './guard'
_issueNotifier = require '../notification/issue'


# exports.get = (client, cb)->

afterUpdateNotifier = (data, member_id)->
  #新建任务不触发事件
  return if not data.id

  #指定了责任人，或者计划完成时间，触发接受任务的通知
  if data.owner or data.plan_finish_time
    isChangeExpire = !!data.plan_finish_time
    _issueNotifier.takeTask member_id, data.issue_id, isChangeExpire, data.id

  #更改了任务状态，触发状态变更的通知
  else if data.status
    _issueNotifier.changeStatus member_id, data.issue_id, data.id

exports.save = (client, cb)->
  member_id = client.member.member_id
  data = client.body
  data.id = client.params.id if client.params.id

  # 新建时需要记录创建时间和创建者并将状态标记为doing
  if !data.id
    data.status = 'doing' 
    data.creator = member_id
    data.timestamp = new Date().valueOf() 
  data.issue_id = client.params.issue_id
  data.project_id = client.params.project_id
  # data.plan_finish_time = client.body.plan_finish_time if client.body.plan_finish_time
  # data.finish_time = client.body.finish_time if client.body.finish_time
  
  # 处理当时间为空时会自动保存为0的情况
  delete data.finish_time if !data.finish_time
  delete data.plan_finish_time if !data.plan_finish_time

  # 完成任务时走完成任务的逻辑

  if data.status is 'done' and data.id
	  _entity.issue_split.finishedIssue data, client.member.member_id, (err)->
      afterUpdateNotifier data, member_id

      cb err
  else
    _entity.issue_split.save data, (err, id)->
      afterUpdateNotifier data, member_id
      cb err


exports.delete = (client, cb)->
  _entity.issue_split.remove id:client.params.id, cb
