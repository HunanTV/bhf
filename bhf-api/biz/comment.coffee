###
  评论
###
_path = require 'path'
_async = require 'async'
_marked = require 'marked'

_memberEntity = require '../entity/member'
_notifier = require '../notification'
_guard = require './guard'
_issueBiz = require './issue'
_entity = require '../entity/comment'
_common = require '../common'

exports.put = (client, cb)->
  project_id = client.params.project_id
  issue_id = client.params.issue_id
  id = client.params.id

  data =
    content: client.body.content
    id: id

  queue = []
  queue.push(
    (done)-> _guard.allowUpdateComment project_id, id, client.member, (err)-> done err
  )

  queue.push(
    (done)-> _entity.save data, done
  )

  _async.waterfall queue, (err)->
    return cb err

    _issueBiz.writeLog client.member.member_id, issue_id, "修改评论->#{id}"

#保存comment
exports.post = (client, cb)->
  member_id = client.member.member_id
  data = client.body
  data.id = client.params.id
  data.project_id = client.params.project_id
  data.issue_id = client.params.issue_id
  data.creator = member_id
  data.timestamp = Number(new Date())
  #类型为markdown
  if data.content_type is 'markdown' then data.content = _marked(data.content)

  queue = []
  #请求权限
  queue.push(
    (done)->
      #wiki和运维类的，所有人都可以评论
      return done null if _guard.projectIsWiki(data.project_id) || _guard.projectIsService(data.project_id)
      _guard.projectPermission data.project_id, client.member, '*-g', (err)-> done err
  )

  #保存数据
  queue.push(
    (done)-> _entity.save data, done
  )

  _async.waterfall queue, (err, id)->
    id = data.id || id
    cb err, id: id

    _notifier.addComment member_id, data.issue_id, data.content
    #通知参与者以及提到的人
    filter = []
    #仅限管理员可以提到所有人
    filter.push 'all' if client.member.role isnt 'a'
    names = _common.extractMention filter, data.title, data.content
    _notifier.mention names, data.issue_id, id



exports.get = (client, cb)->
  cond =
    # project_id: client.params.project_id
    issue_id: client.params.issue_id
    status: 0
  pagination = _entity.pagination client.query.pageIndex, client.query.pageSize
  orderByTimestamp = if /desc/i.test(client.query.orderBy) then 'DESC' else 'ASC'

  _entity.fetch cond, pagination, orderByTimestamp, cb

#删除
exports.delete = (client, cb)->
  id = client.params.id
  project_id = client.params.project_id
  issue_id = client.params.issue_id
  data =
    status: 1
    id: id
  queue = []
  queue.push(
    (done)-> _guard.allowUpdateComment project_id, id, client.member, (err)-> done err
  )

  queue.push(
    (done)-> _entity.save data, (err)-> done err
  )

  _async.waterfall queue, (err)->
    cb err
    _issueBiz.writeLog client.member.member_id, issue_id, "删除评论->#{id}"

exports.toString = -> _path.basename __filename