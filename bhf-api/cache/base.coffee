_async = require 'async'
_ = require 'lodash'

_entity = require '../entity'
_common = require '../common'

module.exports = class BaseCacheEntity
  constructor: ()->
    @data = {}


  init: -> throw new Error('init必需重载')

  #加载整个table的数据
  loadTable: (entity, fields, key, cond, cb)->
    if typeof cond is 'function'
      cb = cond
      cond = {}

    self = @
    options = fields: fields
    entity.find cond, options, (err, results)->
      for item in results
        self.data[item[key]] = item
      cb? err, results

