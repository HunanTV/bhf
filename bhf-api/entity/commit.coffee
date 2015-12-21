_BaseEntity = require('bijou').BaseEntity
_async = require 'async'

class Commit extends _BaseEntity
  constructor: ()->
    super require('../schema/commit').schema

  #根据git用户名查找对应的用户id
  findMemberWithGitUser: (gitUser, cb)->
    sql = "SELECT id FROM member WHERE LOWER(git) = LOWER('#{gitUser}') LIMIT 1"
    this.entity().knex.raw(sql).then (result)->
      rows = result[0]
      member_id = if rows.length > 0 then rows[0].id else 0
      cb null, member_id

  #获取commit
  fetch: (cond, pagination, cb)->
    options =
      orderBy: timestamp: 'desc'
      pagination: pagination
      fields: (query)->
        fields = '*, (SELECT realname FROM member WHERE A.creator = member.id) AS realname'
        query.select(query.knex.raw(fields))

    @find cond, options, cb


module.exports = new Commit