_BaseEntity = require('bijou').BaseEntity
_async = require 'async'
_ = require 'lodash'

class GitMap extends _BaseEntity
  constructor: ()->
    super require('../schema/git_map').schema

  #获取一个项目的gits
  findProjectGits: (project_id, cb)->
    cond = type: 'project', target_id: project_id
    options =
      fields: ['git']
    @find cond, options, cb

  #根据目标id
  findMemberGits: (member_id, cb)->
    cond = type: 'member', target_id: member_id
    @find cond, cb

  #根据条件查找映射目标的id
  findTargetId: (type, git, cb)->
    cond = type: type, git: git
    @findOne cond, (err, result)-> cb err, result?.target_id

  #根据git邮箱查找对应的用户id
  findMemberId: (mail, cb)-> @findTargetId 'member', mail, cb

  #根据项目的git地址查找项目编号
  findProjectId: (url, cb)-> @findTargetId 'project', url, cb

  #保存git
  saveGits: (target_id, type, gits, cb)->
    self = @
    queue = []
    queue.push(
      (done)->
        #删除现在的
        cond = type: type, target_id: target_id
        self.remove cond, done
    )

    queue.push(
      (done)->
        return done(null) if not gits?.length
        data = []
        bastData = type: type, target_id: target_id
        data.push _.extend git: git, bastData for git in gits
        entity = self.entity().insert(data)
        #console.log entity.toString()
        entity.exec done
    )

    _async.series queue, cb


module.exports = new GitMap