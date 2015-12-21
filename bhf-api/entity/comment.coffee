###
  评论
###
_BaseEntity = require('bijou').BaseEntity
_async = require 'async'

#定义一个Project类
class Comment extends _BaseEntity
  constructor: ()->
    super require('../schema/comment').schema

  #获取数据，会返回realname
  fetch: (condition, pagination, orderByTimestamp, cb)->
    #选项
    options =
      orderBy: timestamp: orderByTimestamp
      fields: (query)->
        query.select query.knex.raw('*, (SELECT realname FROM member WHERE member.id = A.creator) AS creator_name')
      pagination: pagination

    @find condition, options, cb

module.exports = new Comment