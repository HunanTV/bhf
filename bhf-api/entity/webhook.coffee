###
  webhook
###
_BaseEntity = require('bijou').BaseEntity
_async = require 'async'
_common = require '../common'

class Webhook extends _BaseEntity
  constructor: ()->
    super require('../schema/webhook').schema


  #如果存在，则更新
  saveOrUpdate: (data, cb)->
    cond = project_id: data.team_id, trigger: data.trigger
    self = @
    @findOne cond, (err, result)->
      data.id = result.id if result
      self.save data, cb

module.exports = new Webhook