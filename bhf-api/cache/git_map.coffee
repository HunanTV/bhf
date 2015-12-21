#    Author: 易晓峰
#    E-mail: wvv8oo@gmail.com
#    Date: 6/24/15 4:18 PM
#    Description: git地址影射的缓存

_ = require 'lodash'
_BaseCache = require './base'
_entity = require '../entity'

class GitMapCacheEntity extends _BaseCache
  init: (cb)-> @load cb

  #加载列表，如果没有指定cond，则加载所有数据
  load: (cond, cb)->
#    console.log "刷新git_map", cond
    @data = {}
    if _.isFunction cond
      cb = cond
      cond = {}

    fields = ['target_id', 'type', 'git', 'git_id']
    @loadTable _entity.git_map, fields, 'git', cond, cb

  get: (git)-> @data[git]

module.exports = new GitMapCacheEntity