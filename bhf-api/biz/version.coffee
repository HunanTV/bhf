_entity = require '../entity'
_commom = require '../common'
_ = require 'lodash'
_async = require 'async'
_http = require('bijou').http
_guard = require './guard'

exports.get = (client, cb)->
  id = client.params.id
  return _entity.version.findById id, cb if id

  cond = project_id: client.params.project_id
  status = client.query.status

  options =
    orderBy: status: 'ASC'
    beforeQuery: (query)->
      if status is 'available'
        query.whereIn 'status', ['active', 'deactive']
      else if status
        query.where 'status', '=', status

  _entity.version.find cond, options, cb

exports.delete = (client, cb)->
  id = client.params.id
  project_id = client.params.project_id

  queue = []
  #获取权限
  queue.push(
    (done)->
      _guard.allowRemoveVersion project_id, id, client.member, (err)-> done err
  )

  #更新version_id
  queue.push(
    (done)->
      cond = project_id: project_id, version_id: id
      _entity.issue.update cond, version_id: null, done
  )


  queue.push(
    (done)->
      _entity.version.removeById id, done
  )

  _async.waterfall queue, cb


#修改数据
exports.save = (client, cb)->
  data =
    id: client.params.id
    project_id: client.params.project_id
    title: client.body.title
    short_title: client.body.short_title
    status: client.body.status

  isNew = not data.id
  data.status = 'deactive' if isNew
  _commom.cleanUndefined data

  #检查版本状态是否正确
  if data.status and not _commom.validVersionStatus(data.status)
    return cb _http.notAcceptableError('参数错误：版本状态不正确')

  #如果不是修改数据，则名称必需输入
  if isNew and not data.title
    return cb _http.notAcceptableError('版本名称必需输入')


  queue = []
  #检查对该项目是否有权限
  queue.push(
    (done)->
      _guard.projectPermission data.project_id, client.member, (err)-> done err
  )

  #检查数据是否重复
  queue.push(
    (done)->
      return done null if not(data.title or data.short_title)

      matches = {}
      matches.title = data.title if data.title
      matches.short_title = data.short_title if data.short_title

      cond = project_id: data.project_id

      notMatches = {}
      notMatches.id = data.id if not isNew

      _entity.version.exists matches, cond, notMatches, (err, exists)->
        return done err if err
        err = _http.notAcceptableError('版本名称或者版本简称在此项目中已经存在') if exists
        done err
  )

  #如果是激活某个版本，则将active的版本改为deactive
  queue.push(
    (done)->
      #没有修改状态，或者状态没有激活，则不用修改其它版本的状态，因为同一时间只能激活一个版本
      return done null if isNew or data.status isnt 'active'
      cond = project_id: data.project_id, status: 'active'
      _entity.version.update cond, status: 'deactive', done
  )

  queue.push(
    (done)-> _entity.version.save data, done
  )

  _async.waterfall queue, (err)-> cb err


exports.toString = -> 'biz.version'