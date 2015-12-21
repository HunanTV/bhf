_entity = require '../entity'
_common = require '../common'
_ = require 'lodash'
_async = require 'async'
_path = require 'path'
_http = require('bijou').http
_guard = require './guard'
_notifier = require '../notification'

# 新增/修改
exports.save = (client, cb)->
  data = client.body
  data.id = client.params.id
  isUpdate = Boolean(data.id)
  


  #更新，则检查leader的权限
  queue = []
  queue.push(
    (done)->
      return done null if not isUpdate
      #修改仅leader可以
      _guard.teamPermission data.id, client.member.member_id, (err)-> done err
  )
  #检测是否存在同名团队
  queue.push(
    (done)->
      cond =
        name: data.name
      _entity.team.findOne cond, (err, result)->
        return done err if err
        err = _http.notAcceptableError("已存在名为#{data.name}的团队") if result
        done err
  )
  #team不存在，创建team
  queue.push(
    (done)->
      data.creator = client.member.member_id if not isUpdate
      _entity.team.save data, (err, id)-> 
        team =
          id: id
          name: data.name
        done err, team
  )
  #新增team后，把创建者加入team并标为leader
  queue.push(
    (team, done)->
      # 创建/修改team后，重新加载team缓存
      # _cache.loadTeam()
      return done null if isUpdate
      cond = 
        team_id: team.id
        member_id: client.member.member_id
        inviter: client.member.member_id
        status: 1
        role: 'l'
      _entity.team_member.save cond, (err)-> 
        done err,team
  )

  _async.waterfall queue, cb



# 查询团队
exports.get = (client, cb)->

  id = client.params.id
  cond = member_id:client.member.member_id
  # 如果有参数有id则返回团队信息
  return getTeamDetails client, cb if id
  # 没有id则返回登录账号所在小组的list

  cond.role = client.query.role if client.query.role
  cond.status = client.query.status if client.query.status

  _entity.team_member.findMyTeam cond, cb


# 删除团队
exports.delete = (client, cb)->
  cond =
    id: client.params.id
  
  cond_team_member = 
    team_id: client.params.id

  _entity.team.remove cond, cb
  _entity.team_member.remove cond_team_member, cb 


# 获取组成员
exports.getMembers = (client, cb)->
  team_id = client.params.team_id
  _entity.team_member.teamMembers {team_id: team_id}, (err,members)->
    
    result = 
      role: getMemberRole members, client.member.member_id
      members: members
    cb err, result



# 新增团队成员
exports.addMember = (client, cb)->
  cond =
    team_id: client.params.team_id
    member_id: client.body.member_id
    inviter: client.member.member_id

  queue = []
  queue.push(
    (done)-> _guard.teamPermission cond.team_id, client.member.member_id, (err)-> done err
  )

  #执行任务，并要求权限
  queue.push(
    (done)->
      _entity.team_member.saveOrUpdate cond, (err)->
        done err
  )  

  _async.waterfall queue, (err)->
    cb err
    return if err

    #通知被邀请者
    _entity.team.findOne id: cond.team_id, (err, result)->
      return if err or not result
      #通知被邀请者
      _notifier.joinTeamInvitation cond.inviter, cond.member_id, result.name

# 编辑团队成员
exports.editMember = (client, cb)->
  cond =
    team_id: client.params.team_id
    member_id: client.params.id
    role: client.body.role
  cond.status = client.body.status if client.body.status
  queue = []
  queue.push(
    (done)-> 
      # 当操作同意邀请的时候不需要权限
      return done null if (parseInt(client.params.id) is parseInt(client.member.member_id) and client.body.status)
      _guard.teamPermission cond.team_id, client.member.member_id, (err)-> done err
  )

  # 检测是否为该团队最后一个leader，如果是则不允许改为普通成员
  queue.push(
    (done)->
      _entity.team_member.checkLastLeader cond, (err)->
        done err
  )
  #执行任务，并要求权限
  queue.push(
    (done)->
      _entity.team_member.saveOrUpdate cond, (err)->
        done err
  )

  _async.waterfall queue, cb

# 删除团队成员
exports.removeMember = (client, cb)->
  cond =
    team_id: client.params.team_id
    member_id: client.params.id

  queue = []
  # 检测权限
  queue.push(
    (done)-> 
      return done null if (parseInt(client.params.id) is parseInt(client.member.member_id))
      _guard.teamPermission cond.team_id, client.member.member_id, (err)-> done err
  )

  # 检测是否为该团队最后一个leader，如果是则不允许删除
  queue.push(
    (done)->
      _entity.team_member.checkLastLeader cond, (err)->
        done err
  )

  #执行任务
  queue.push(
    (done)->
      _entity.team_member.remove cond, (err)->
       done err
  )

  _async.waterfall queue, cb


exports.revieveInvite = (client, cb)->
  cond =
    team_id: client.params.team_id
    member_id: client.params.id
    status: 1

  _entity.team_member.saveOrUpdate cond, (err)->
    done err

getTeamDetails = (client, cb)->
  cond = 
    id: client.params.id
  _entity.team.findOne cond, cb


getMemberRole = (members,member_id)->

  return member.role for member in members when member.member_id is member_id















