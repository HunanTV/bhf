_BaseEntity = require('bijou').BaseEntity
_async = require 'async'
_ = require 'lodash'

class Asset extends _BaseEntity
  constructor: ()->
    super require('../schema/asset').schema

  #获取所有数据
  fetch: (cond, pagination, cb)->
    options =
      fields: ['A.*', 'B.realname AS creator_name']
      orderBy: id: 'DESC'
      pagination: pagination
      beforeQuery: (query)->
        query.join 'member AS B', (-> this.on 'A.creator', '=', 'B.id'), 'left'
        query.where 'A.original_name', 'like', "%#{cond.keyword}%" if cond.keyword


    @find _.pick(cond, 'project_id', 'issue_id'), options, cb

module.exports = new Asset