_common = require '../common'
_config = _common.config
_entity = require '../entity/project_member'
_connect = require './connect'

_async = require 'async'
HASHKEY = "#{_config.redis.unique}:role"

getKey = (project_id, member_id)->
  "role:#{project_id}:#{member_id}"

pushToRedis = (list, cb)->
  index = 0
  _async.whilst(
    -> index < list.length
    (done)->
      row = list[index++]
      return done(null) if not row.member_id
      key = getKey row.project_id, row.member_id
      _connect.redis.hset HASHKEY, key, row.role, done
    cb
  )

#检查用户的角色是否在某个角色列表里面
memberRoleInList = (role, list, isAllow)->
  pattern = if isAllow then /(\+|^)([\w*]+)/ else /(-)([\w*]+)/
  matches = list.match pattern
  return false if not matches

  exists = matches[2]
  #  *表示所有用户，但必需有一个角色存在
  return (role and exists.indexOf('*') >= 0) or exists.indexOf(role) >= 0


exports.init = (cb)->
  self = @
  #_connect.redis.expire HASHKEY, 1000000
  _connect.redis.select _config.redis.database || 0, -> self.loadAll ->

#加载所有用户的权限
exports.loadAll = (cb)->
  #清除现有的
  queue = []

  queue.push(
    (done)-> _connect.redis.del HASHKEY, (err)-> done err
  )

  queue.push(
    (done)-> _entity.find null, done
  )

  queue.push(pushToRedis)

  _async.waterfall queue, cb

#删除某个人的权限
exports.remove = (project_id, member_id, cb)->
  _connect.redis.hdel HASHKEY, getKey(project_id, member_id)

#设置某个用户在项目中的权限
exports.update = (project_id, member_id, role, cb)->
  _connect.redis.hset HASHKEY, getKey(project_id, member_id), role, cb

#获取一个用户在某个项目中的权限
exports.get = (project_id, member_id, cb)->
  return cb(null) if not project_id or not member_id

  _connect.redis.hget HASHKEY, getKey(project_id, member_id), cb

#请求项目级的权限许可
#expectRole，期待
exports.permission = (project_id, member, expectRoles, cb)->
  return cb(null, true) if member.role is 'a'
  @get project_id, member.member_id, (err, role)->
    return cb err, false if err or not role
    allow = exports.roleValidate expectRoles, role
    cb err, allow, role

#检查用户的权限是否合法
#rules: 规则，role：用户所拥有的权限
exports.roleValidate = (rules, role)->
  !memberRoleInList(role, rules, false) and memberRoleInList(role, rules, true)