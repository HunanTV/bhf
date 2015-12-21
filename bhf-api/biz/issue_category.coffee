_entity = require '../entity'
_commom = require '../common'
_ = require 'lodash'
_async = require 'async'
_http = require('bijou').http
_guard = require './guard'

#更新与创建
exports.save = (client, cb)->
  data =
    project_id: client.params.project_id
    title: client.body.title
    short_title: client.body.short_title
    id: client.params.id

  return cb _http.notAcceptableError('分类名称必需输入') if not data.title

  queue = []
  #检测权限
  queue.push(
    (done)->
      _guard.projectPermission data.project_id, client.member, (err)-> done err
  )

  #检测分类与分类名称是否已经存在了
  queue.push(
    (done)->
      matches = title: data.title
      matches.short_title = data.short_title if data.short_title
      cond = project_id: data.project_id
      notMatches = {}
      notMatches.id = data.id if data.id

      _entity.issue_category.exists matches, cond, notMatches, (err, exists)->
        return done err if err
        err = _http.notAcceptableError('分类名或者分类简称在此项目中已经存在') if exists
        done err
  )

  queue.push(
    (done)->
      _entity.issue_category.save data, done
  )

  _async.waterfall queue, cb


exports.delete =  (client, cb)->
  id = client.params.id
  project_id = client.params.project_id

  queue = []
  #检测权限
  queue.push(
    (done)->
      _guard.projectPermission project_id, client.member, (err)-> done err
  )

  #更新所有issue
  queue.push(
    (done)->
      cond = project_id: project_id, category_id: id
      _entity.issue.update cond, category_id: null, done
  )

  #删除数据
  queue.push(
    (done)-> _entity.issue_category.removeById id, done
  )

  _async.waterfall queue, cb


exports.get = (client, cb)->
  project_id = client.params.project_id
  _entity.issue_category.fetchWithCount project_id, cb
