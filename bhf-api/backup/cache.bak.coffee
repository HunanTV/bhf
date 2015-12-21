_async = require 'async'
_ = require 'lodash'
_entity = require './entity'
_common = require './common'

###
  缓存层代码需要重构，计划移到cache文件夹
###

#用于缓存常用资源的kv
_cache =
  #成员
  member: {}
  #项目列表
  project: {}
  #一个项目下有哪些成中
  projectMember: {}
  #项目成员的权限，用于处理项目权限
  projectMemberRole: {}
  #每个用户有哪些项目
  memberProject: {}
  #成员的git地址
  gitMap: {}
  #团队列表
  # team: {}
  #每个项目中有哪些成员
  teamMember: {}
  #每个成员有哪些Team
  memberTeam: {}

#清除某个项目的成员，或者所有项目的成员
cleanProjectMemberRole = (project_id)->
  return _cache.projectMemberRole = {} if not project_id
  for k, item of _cache.projectMemberRole
    continue if item.project_id isnt project_id
    key = projectMemberKey(value.project_id, item.member_id)
    delete _cache.projectMemberRole[key]

#获取项目成员的key
projectMemberRoleKey = (project_id, member_id)-> "#{project_id}_#{member_id}"

#加载整个table的数据
loadTable = (entity, cacheName, fields, key, cb)->
  _cache[cacheName] = {}
  options = fields: fields
  entity.find {}, options, (err, results)->
    for item in results
      _cache[cacheName][item[key]] = item
    return cb err, results if cb
    null

#加载项目
loadProject = exports.loadProject = (cb)->
  loadTable _entity.project, 'project', ['id', 'title', 'flag'], 'id', cb


#加载所有成员到缓存
loadMember = exports.loadMember = (cb)->
  fields = ['id', 'realname', 'email', 'role', 'notification', 'weixin']
  loadTable _entity.member, 'member', fields, 'id', (err, members)->
    index = 0
    _async.whilst(
      -> index < members.length
      (done)-> loadMemberProject members[index++].id, done
      cb
    )

    #序列化用户的设置
    _.map _cache.member, (current)->
      #如果用户的设置存在，则转换为JSON，否则转换为空数组
      current.notification = _common.parseJSON current.notification

#加载某个项目的成员
loadProjectMemberRole = exports.loadProjectMemberRole = (project_id, cb)->
  #清除所有项目成员，或者某个项目成员
  cleanProjectMemberRole project_id
  cond = {}
  cond.project_id = project_id if project_id
  _entity.project_member.find cond, (err, results)->
    members = []
    for item in results
      if _cache.projectMember[item.project_id]
        _cache.projectMember[item.project_id].push item.member_id
      else
        _cache.projectMember[item.project_id] = [item.member_id]

      members.push item.member_id
      key = projectMemberRoleKey(item.project_id, item.member_id)
      _cache.projectMemberRole[key] = item.role
    cb? null


#加载成员的git
loadGitMap = exports.loadGitMap = (cb)->
  fields = ['target_id', 'type', 'git']
  loadTable _entity.git_map, 'gitMap', fields, 'git', cb

#加载一个用户所有的项目
loadMemberProject = exports.loadMemberProject = (member_id, cb)->
  _entity.project_member.findMyProject member_id, (err, projects)->
    _cache.memberProject[member_id] = (project.project_id for project in projects)
    cb? null

# #加载所有团队
# loadTeam = exports.loadTeam = (cb)->
#   loadTable _entity.team, 'team', ['id', 'name', 'creator'], 'id', cb

#加载团队成员列表
#loadTeamMember cb 加载所有成员
#loadTeamMember team_id, cb 根据 team_id加载成员，用于更新team成员的时候
loadTeamMember = exports.loadTeamMember = (args...)->
  #只获取已经邀请的用户
  cond = status: 1
  if args.length is 1
    cb = args[0]
  else
    cb = args[1]
    cond.team_id = args[0]

  teamMember = _cache.teamMember
  _entity.team_member.find cond, (err, result)->
    return cb? err if err
    _.map result, (current)->
      team = teamMember[current.team_id] = [] if not (team = teamMember[current.team_id])
      team.push current.member_id

    cb? null

#加载成员所属的team，此方法应该在loadMember后调用
#loadMemberTeam cb //加载所有成员所属的team
#loadMemberTeam member_id, cb //加载
loadMemberTeam = exports.loadMemberTeam = (args...)->
  #只处理已经接受邀请的用户
  cond = status: 1
  if args.length is 1
    cb = args[0]
  else
    cb = args[1]
    cond.member_id = args[0]

  memberTeam = _cache.memberTeam
  _entity.team_member.find cond, (err, result)->
    return cb? err if err
    _.map result, (current)->
      member = memberTeam[current.member_id] = [] if not (member = memberTeam[current.member_id])
      member.push current.team_id
    cb? null

#加载所有缓存，一般是在启动的时候
exports.loadAll = (cb)->
  task = {
    member: loadMember
    gitMap: loadGitMap
    projectMemberRole: (done)-> loadProjectMemberRole null, done
    project: loadProject
    # team: loadTeam
    teamMember: loadTeamMember
  }

  _async.series task, -> cb?()

#根据真实姓名查找成员
exports.getMemberWithRealname = (realname)->
  for key, member of _cache.member
    return member if member.realname is realname

#获取一个用户下的所有项目
exports.getMemberProject = (member_id)-> _cache.memberProject[member_id] || []
#获取用户
exports.getMember = (member_id)-> _cache.member[member_id]
#获取所有的用户
#exports.getAllMember = -> _cache.member
#获取成员在项目中的权限
exports.getProjectMemberRole = (project_id, member_id)->
  _cache.projectMemberRole[projectMemberRoleKey(project_id, member_id)]

#获取gitMap对应的key，因为project和用户的git不可能一致，所以不用考虑类型
exports.getGitMapTarget = (git)-> _cache.gitMap[git]?.target_id

#获取缓存中的项目
exports.getProject = (project_id)-> _cache.project[project_id]

#获取缓存中的团队
# exports.getTeam = (team_id)-> _cache.team[team_id]

#获取所有的项目
exports.getAllProject = ->  _cache.project

#获取一个项目的所有成员
exports.getAllMemberOfProject = (project_id)->
  _cache.projectMember[project_id] || []