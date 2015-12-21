_BaseEntity = require('bijou').BaseEntity
_async = require 'async'

#定义一个Project类
class AssetIssueRelation extends _BaseEntity
  constructor: ()->
    super require('../schema/asset_issue_relation').schema

  #解除某个issue下与asset的所有关系
  unlinkAll: (issue_id, cb)->
    @entity().where('issue_id', issue_id).del().exec cb

  #替换掉现有的关系
  replaceAll: (assets, issue_id, cb)->
    self = @
    @unlinkAll issue_id, (err)->
      count = 0
      #批量插入数据
      _async.whilst(
        -> count < assets.length
        (done)->
          relation_data = issue_id: issue_id, asset_id: assets[count++]
          self.save relation_data, done
        cb
      )

module.exports = new AssetIssueRelation