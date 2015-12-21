#成员缓存

_ = require 'lodash'
_BaseCache = require './base'
_entity = require '../entity'
_common = require '../common'

class MemberCacheEntity extends _BaseCache
  init: (cb)-> @load cb

  #加载用户的缓存，如果指定用户id，则加载所有用户
  load: (member_id, cb)->
    self = @
    if _.isFunction member_id
      cb = member_id
      member_id = null
      cond = {}
    else
      cond = id: member_id

#    console.log "刷新member", cond

    fields = ['id', 'realname', 'email', 'role', 'notification', 'weixin', 'gitlab_token']
    @loadTable _entity.member, fields, 'id', cond, (err, members)->
      return cb err if err

      #如果只加载一个用户，取当前用户，否则取所有用户数据
      data = if member_id then [self.data[member_id]] else self.data

      #序列化用户的设置
      _.map data, (current)->
        #如果用户的设置存在，则转换为JSON，否则转换为空数组
        current.notification = _common.parseJSON current.notification

      cb err

  #根据用户id，获取用户的基本信息
  get: (member_id)-> @data[member_id]

  #获取所有用户
  all: -> @data

module.exports = new MemberCacheEntity