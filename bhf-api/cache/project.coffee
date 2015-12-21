#    Author: 易晓峰
#    E-mail: wvv8oo@gmail.com
#    Date: 6/29/15 3:51 PM
#    Description: 项目信息的缓存，主要缓存项目类型

_ = require 'lodash'
_BaseCache = require './base'
_entity = require '../entity'

class ProjectCacheEntity extends _BaseCache
  init: (cb)-> @load cb

  #加载列表，如果没有指定project_id，则加载所有数据
  load: (project_id, cb)->
#    console.log "刷新project", project_id
    @data = {}
    if _.isFunction project_id
      cb = project_id
      cond = {}
    else
      cond = project_id: project_id

    fields = ['id', 'flag']
    @loadTable _entity.project, fields, 'id', cond, cb

  get: (project_id)-> @data[project_id]

module.exports = new ProjectCacheEntity