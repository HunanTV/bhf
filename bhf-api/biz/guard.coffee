#权限与角色
_projectBiz = require './project'
_entity = require '../entity'
_http = require('bijou').http
_async = require 'async'
_cache = require '../cache'
_enum = require('../common').enumerate


#检查用户的角色是否在某个角色列表里面
memberRoleInList = (role, list, isAllow)->
  pattern = if isAllow then /(\+|^)([\w*]+)/ else /(-)([\w*]+)/
  matches = list.match pattern
  return false if not matches

  exists = matches[2]
  #  *表示所有用户，但必需有一个角色存在
  return (role and exists.indexOf('*') >= 0) or exists.indexOf(role) >= 0

#检查用户的权限是否合法
#rules: 规则，role：用户所拥有的权限
exports.roleValidate = (rules, role)->
  !memberRoleInList(role, rules, false) and memberRoleInList(role, rules, true)

#检测项目是否为wiki
exports.projectIsWiki = (project_id)->
  project = _cache.project.get(project_id)
  project?.flag is _enum.projectFlag.wiki

#检测项目是否为运维
exports.projectIsService = (project_id)->
  project = _cache.project.get(project_id)
  project?.flag is _enum.projectFlag.service

#获取针对项目的权限许可
exports.projectPermission = (project_id, member, expectRoles, cb)->
  #如果没有提供expectRoles，则用l权限校验
  if typeof expectRoles is 'function'
    cb = expectRoles
    expectRoles = 'l'

  #管理员拥有所有的权限
  return cb(null, true) if member.role is 'a'

  role = _cache.projectMember.getRole project_id, member.member_id

  allow = exports.roleValidate expectRoles, role
  return cb _http.forbiddenError() if not allow

  cb null, allow, role


#是否允许删除素材
exports.allowRemoveAsset = (project_id, asset_id, member, cb)->
  queue = []
  #如果用户的权限是leader和admin的话，允许删除
  queue.push(
    (done)-> exports.projectPermission project_id, member, (err, allow)-> done null, allow
  )

  #检查素材是否是自己的，用户可以删除自己上传的素材
  queue.push(
    (allow, done)->
      #如果用户是leader，则有权限删除
      return done null if allow

      _entity.asset.findById asset_id, (err, result)->
        if not result
          #没有这条数据
          err = _http.notFoundError()
        else if result and result.creator isnt member.member_id
          #不是用户自己
          err = _http.forbiddenError()

        done err
  )

  _async.waterfall queue, cb


#leader可以操作，自己也可以操作(删除/编辑)
exports.allowUpdateComment = (project_id, comment_id, member, cb)->
  queue = []
  #请求权限
  queue.push(
    (done)-> exports.projectPermission project_id, member, (err, allow)-> done null, allow
  )

  queue.push(
    (allow, done)->
      return done null if allow

      _entity.comment.findById comment_id, (err, result)->
        if not result
          #没有这条数据
          err = _http.notFoundError()
        else if result and result.creator isnt member.member_id
          #不是用户自己
          err = _http.forbiddenError()

        done err
  )

  _async.waterfall queue, cb


#是否可以删除版本的权限
exports.allowRemoveVersion = (project_id, version_id, member, cb)->
  queue = []
  #请求权限
  queue.push(
    (done)-> exports.projectPermission project_id, member, (err, allow)-> done err, allow
  )

  queue.push(
    (allow, done)->
      #检查当前的版本是否为活动版本，活动版本不允许删除
      _entity.version.findById version_id, (err, result)->
        return done err if err
        err = _http.notAcceptableError('活动的版本无法被删除') if result.status is 'active'
        done err
  )

  _async.waterfall queue, cb

  #操作团队的权限
exports.teamPermission = (team_id, member_id, cb)->
  cond =
    team_id : team_id
    member_id : member_id
  _entity.team_member.findOne cond, (err,result)->
    return cb err if err
    return cb(_http.forbiddenError(), false) if !result
    return cb(null, true) if result.role is 'l'
    return cb(_http.forbiddenError(), false)
