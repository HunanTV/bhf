###
  log
###
_BaseEntity = require('bijou').BaseEntity
_async = require 'async'
_common = require '../common'

class Log extends _BaseEntity
  constructor: ()->
    super require('../schema/log').schema

  fetch: (type, target_id, pagination, cb)->
    cond = type: type, target_id: target_id
    #目前仅获取最新10条的log记录
    options =
      fields: ['A.*', 'B.realname']
      orderBy: id: 'DESC'
      pagination: pagination
      beforeQuery: (query)->
        query.join 'member AS B', (-> this.on 'A.member_id', '=', 'B.id'), 'LEFT'

    @find cond, options, cb

module.exports = new Log