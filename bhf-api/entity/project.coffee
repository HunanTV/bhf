_BaseEntity = require('bijou').BaseEntity
_async = require 'async'
_projectMemberEntity = require './project_member'
_gitMapEntity = require './git_map'
_ = require 'lodash'
_common = require '../common'
_http = require('bijou').http
_versionEntity = require './version'
_categoryEntity = require './issue_category'

#定义一个Project类
class Project extends _BaseEntity
  constructor: ()->
    super require('../schema/project').schema

  unionSave: (data, member, cb)->
    isUpdate = Boolean(data.id)
    self = @
    gits = data.gits
    gits = [gits] if not (gits instanceof Array)

    queue = []
    queue.push(
      (done)->  self.save data, (err, id)->
        data.id = data.id || id
        done err
    )

    #添加默认的分类
    queue.push(
      (done)->
        return done null if isUpdate
        cdata = [
          {title: 'bug', short_title: 'bug', project_id: data.id}
          {title: '需求', short_title: 'xq', project_id: data.id}
        ]

        _categoryEntity.insert cdata, (err)-> done err
    )

    #添加默认的版本
    queue.push(
      (done)->
        return done null if isUpdate
        vdata =
          title: 'default'
          short_title: 'default'
          status: 'active'
          project_id: data.id

        _versionEntity.save vdata, (err)-> done err
    )

    #将用户添加为leader
    queue.push(
      (done)->
        #管理员添加，则不添加任何用户，更新也不需要添加用户
        return done null if isUpdate or member.id is 'a'

        #把当前用户加入到项目，权限为leader
        member =
          project_id: data.id
          member_id: member.member_id
          role: 'l'

        _projectMemberEntity.saveOrUpdate member, (err)-> done err
    )

    #添加git列表
    queue.push(
      (done)-> _gitMapEntity.saveGits data.id, 'project', gits, done
    )

    _async.waterfall queue, (err)->
      result = if isUpdate then {} else id: data.id
      cb err, result

#  #获取一个项目的详细数据
#  projectDetails: (project_id, cb)->
#    result = {}
#    self = @
#    queue = []
#    #找到项目
#    queue.push((done)->self.findById project_id, done)
#    #获取所有的成员
#    queue.push(
#      (project, done)->
#        return done _http.notFoundError() if not project
#
#        result = _.extend {}, project
#        _projectMemberEntity.projectMembers project_id, (err, members)->
#          result.members = members
#          done err, result
#    )
#
#    #获取一个项目下所有的git地址
#    queue.push(
#      (project, done)->
#        _gitMapEntity.findProjectGits project_id, (err, gits)->
#          project.gits = gits
#          done err, project
#    )
#
#    _async.waterfall queue, cb

  fetch: (cond, pagination, cb)->
    self = @
    rightTable = "(SELECT DISTINCT M.project_id FROM project_member M LEFT JOIN project P ON P.id = M.project_id WHERE (P.status IS NULL OR P.status <> 'trash') AND P.id IS NOT NULL"
    rightTable += " AND M.member_id = #{cond.member_id}" if cond.member_id
    rightTable += " AND M.role = '#{cond.role}'" if cond.role
    rightTable += " OR P.flag = 1" if cond.special
    rightTable += ') AS tmp'

    #最新版本的id
    versionField = "(SELECT id FROM version Z WHERE Z.project_id = A.id AND Z.status = 'active' LIMIT 1) active_version"

    #获取所有任务的数量
    allTaskField = "(SELECT COUNT(*) FROM issue WHERE tag IN ('issue', 'form')
      AND status <> 'trash' AND project_id = A.id "
    
    allTaskField += " AND (owner = #{cond.member_id} OR creator = #{cond.member_id}) " if cond.myself

    allTaskField += ") AS task_total"

    undoneTaskField = "(SELECT COUNT(*) FROM issue WHERE tag IN ('issue', 'form')
      AND (status = 'new' OR status = 'doing' OR status = 'pause')
      AND project_id = A.id "
    
    undoneTaskField += " AND (owner = #{cond.member_id} OR creator = #{cond.member_id}) " if cond.myself

    undoneTaskField += ") AS undone_task_total"

    favoriteField = "(SELECT COUNT(*) FROM favorite WHERE
      favorite.target_id = A.id AND favorite.type = 'project'
      AND favorite.member_id = #{cond.member_id}) AS favorite"

    memberTotalField = "(SELECT
          COUNT(*)
      FROM
          project_member
      WHERE
          project_id = A.id) AS member_total"

    fields = ['A.*',
              @raw(versionField),
              @raw(allTaskField),
              @raw(undoneTaskField),
              @raw(favoriteField),
              @raw(memberTotalField)]

    #获取用户的权限
    roleField = "(SELECT role FROM project_member Y
      WHERE Y.project_id = A.id
      AND Y.member_id = #{cond.member_id}
      LIMIT 1) AS role"

    fields.push @raw(roleField) if cond.member_id

    options =
      pagination: pagination
      orderBy: favorite: 'DESC', flag: 'ASC', timestamp: 'DESC'
      fields: fields
      beforeQuery: (query)->
        query.where 'A.title', 'like', "%#{cond.keyword}%" if cond.keyword
        return if not cond.member_id
        query.join self.raw(rightTable), (->this.on 'A.id', '=', 'tmp.project_id'), 'RIGHT'

    @find {}, options, cb
    

# 获取一个项目的所有状态
#  getStatus: (project_id, cb)->
#    sql = "select status, count(*) total from issue where project_id = #{project_id} group by status"
#    @entity().knex.raw(sql).exec cb

  #改变project的状态
  changeStatus: (project_id, status, cb)->
    data = {
      id: project_id,
      status: status
    }

    #修改状态
    @save data, cb

module.exports = new Project