_BaseEntity = require('bijou').BaseEntity
_async = require 'async'
_ = require 'lodash'

#定义一个Project类
class ProjectMember extends _BaseEntity
  constructor: ()->
    super require('../schema/project_member').schema

  #获取一个项目下的所有成员
  projectMembers: (project_id, fields, cb)->
    if typeof fields is 'function'
      cb = fields
      fields = ['B.username', 'B.id AS member_id', 'A.role', 'B.email', 'B.realname']

    cond = project_id: project_id
    options =
      fields: fields
      beforeQuery: (query)->
        query.join 'member AS B', (-> this.on 'A.member_id', '=', 'B.id'), 'left'

    @find cond, options, cb

  #获取我的项目
  findMyProject: (member_id, role, cb)->
    #允许第二参数是callback
    if typeof role is 'function'
      cb = role
      role = null

    subsql = if role then " AND role = '#{role}'" else ''
    sql = "SELECT project_id, B.title
      FROM project_member A LEFT JOIN project B ON A.project_id = B.id
      WHERE 1 = 1#{subsql} AND member_id = #{member_id} GROUP BY project_id"

    @execute sql, cb

  #如果存在，则更新
  saveOrUpdate: (data, cb)->
    cond = project_id: data.project_id, member_id: data.member_id
    self = @
    @findOne cond, (err, result)->
      data.id = result.id if result
      data.role = data.role || 'd'
      self.save data, cb

  #批量添加成员
  addMembers: (project_id, members, cb)->
    baseData = project_id: project_id, role: 'd'
    data = []
    (data.push(_.extend(member_id: item, baseData)) if item) for item in members
    return cb(null) if not data.length
    @entity().insert(data).exec (err)-> cb err


  #移除项目中的某个成员
  removeMember: (project_id, member_id, cb)->
    cond = project_id: project_id, member_id: member_id
    @remove cond, cb

module.exports = new ProjectMember