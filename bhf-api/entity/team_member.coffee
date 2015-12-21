_BaseEntity = require('bijou').BaseEntity
_async = require 'async'
_ = require 'lodash'
_http = require('bijou').http

class TeamMember extends _BaseEntity
  constructor: ()->
    super require('../schema/team_member').schema

  #获取一个团队下的所有成员
  teamMembers: (cond, cb)->
    # if typeof fields is 'function'
    #   cb = fields
    #   fields = ['B.username', 'B.id AS member_id', 'A.role', 'B.email', 'B.realname', "A.status"]

    # cond = team_id:team_id

    # options =
    #   fields: fields
    #   beforeQuery: (query)->
    #     query.join 'member AS B', (-> this.on 'A.member_id', '=', 'B.id'), 'left'

    # @find cond, options, cb



    sql = "SELECT B.username,B.id AS member_id,A.role,B.email,B.realname,A.status 
           FROM team_member A LEFT JOIN member B ON A.member_id=B.id 
           WHERE 1=1 "
    sql += " AND A.team_id=#{cond.team_id}" if cond.team_id
    sql += " AND A.status=#{cond.status}" if cond.status
    @execute sql, cb

  #获取我的团队
  findMyTeam: (cond, cb)->
    sql = "SELECT A.team_id, A.member_id, A.status, B.name, C.realname AS inviter_name
      FROM team_member A LEFT JOIN team B ON A.team_id = B.id
      LEFT JOIN member C ON A.inviter = C.id
      WHERE member_id = #{cond.member_id} "
    sql += " AND A.role = '#{cond.role}' " if cond.role
    sql += " AND A.status = '#{cond.status}' " if cond.status
    sql += " GROUP BY A.team_id "
    @execute sql, cb


  #如果存在，则更新
  saveOrUpdate: (data, cb)->
    cond = team_id: data.team_id, member_id: data.member_id
    self = @
    @findOne cond, (err, result)->
      data.id = result.id if result
      data.role = data.role || 'm'
      self.save data, cb

  #批量添加成员
  addMembers: (team_id, members, cb)->
    baseData = team_id: team_id, role: 'd'
    data = []
    (data.push(_.extend(member_id: item, baseData)) if item) for item in members
    return cb(null) if not data.length
    @entity().insert(data).exec cb


  #移除团队中的某个成员
  removeMember: (team_id, member_id, cb)->
    cond = team_id: team_id, member_id: member_id
    @remove cond, cb


  checkLastLeader: (data, cb)->
    queue = []
    self = @
    # 当前成员是不是leader
    queue.push(
      (done)-> 
        cond = team_id: data.team_id, member_id: data.member_id
        self.findOne cond, (err, result)->
          return done err, false if !result or result.role isnt 'l'
          done err, true
    )

    #是否只有一个leader
    queue.push(
      (isLeader, done)->
        return done null if !isLeader
        sql = "SELECT COUNT(*) AS count FROM team_member WHERE team_id=#{data.team_id} AND role='l'"

        self.execute sql, (err, result)->
          err = _http.notAcceptableError("该操作不允许对团队最后一个leader进行") if parseInt(result[0].count) < 2
          done err
    )

    _async.waterfall queue, cb


module.exports = new TeamMember

















