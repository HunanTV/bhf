#    Author: 易晓峰
#    E-mail: wvv8oo@gmail.com
#    Date: 6/24/15 4:17 PM
#    Description:
#       项目的成员列表，包括一个成员的所有项目，以及一个项目所所有成员列表
#       初始化之前，必需先初始化成员与项目列表

_ = require 'lodash'
_async = require 'async'

_BaseCache = require './base'
_entity = require '../entity'

class MemberProjectCacheEntity extends _BaseCache
  init: (cb)->
    @data = project: {}, member: {}, role: {}
    @loadMemberOfProject cb

  #根据条件，清除缓存
  cleanProject: (project_id)->
    #如果指定了项目，则清除掉对应项目的缓存
    if project_id
      @data.project[project_id] = []
      @data.role[project_id] = {}
    else #否则清除掉所有的缓存
      @data.project = {}
      @data.role == {}


  #将用户在项目中的角色写入缓存，self.data.role.项目id.用户id
  setMemberRole: (item)->
    find = @data.role[item.project_id] = {} if not (find = @data.role[item.project_id])
    find[item.member_id] = item.role

  #将一个项目的成员列表写入缓存，获取一个项目的所有成员：self.data.project.项目id
  setMembersOfProject: (item)->
    find = @data.project[item.project_id] = [] if not (find = @data.project[item.project_id])
    find.push item.member_id

  #将一个成员的项目列表写入缓存，获取某个成员的所有项目：self.data.member.成员id
  setProjectsOfMember: (item)->
    find = @data.member[item.member_id] = [] if not (find = @data.member[item.member_id])
    find.push item.project_id

  #同时更新项目和成员的缓存，一般用于添加成员，删除成员
  load: (project_id, member_id)->
    @loadProjectOfMember member_id, ->
    @loadMemberOfProject project_id, ->

  #加载一个用户的所有项目列表，必需指定member_id
  loadProjectOfMember: (member_id, cb)->
#    console.log "加成成员的项目缓存", member_id

    self = @
    #把用户的项目列表先清掉
    @data.member[member_id] = []
    cond = member_id: member_id

    #加载用户的所有项目
    _entity.project_member.find cond, (err, result)->
      if not err then self.setProjectsOfMember item for item in result
      cb? err

  #加载一个项目的所有成员
  loadMemberOfProject: (project_id, cb)->
#    console.log "加成项目的成员缓存", project_id

    self = @
    if _.isFunction project_id
      cb = project_id
      cond = {}
      project_id = null
    else
      cond = project_id: project_id

    #清掉项目的成员，以及项目成员的权限
    @cleanProject project_id

    _entity.project_member.find cond, (err, result)->
      return cb err if err

      for item in result
        #设置项目的成员列表
        self.setMembersOfProject item
        #设置用户在项目中的权限
        self.setMemberRole item
        #设置一个用户拥有的项目，只有在没有指定项目id的情况，才去加载成员拥有的项目列表
        #因为一个成员可能拥有多个项目。
        self.setProjectsOfMember item if not project_id

      cb null

  #获取一个用户所有的项目
  getProjects: (member_id)-> @data.member[member_id]
  #获取一个项目所有的成员
  getMembers: (project_id)-> @data.project[project_id]
  #获取用户在特定项目中的权限
  getRole: (project_id, member_id)-> @data.role[project_id]?[member_id]


module.exports = new MemberProjectCacheEntity