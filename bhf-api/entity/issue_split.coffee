###
  用户关注issue
###
_BaseEntity = require('bijou').BaseEntity
_async = require 'async'
_common = require '../common'
_ = require 'lodash'
_issueEntity = require './issue'

class IssueSplit extends _BaseEntity
  constructor: ()->
    super require('../schema/issue_split').schema

  getSplitIssue: (id, cb)->
  	self = @
  	sql = "SELECT A.*, B.realname from issue_split A LEFT JOIN member B 
  		ON A.owner = B.id
    		WHERE
          A.issue_id = #{id}
        AND
          A.status <> 'trash'"
  	@execute sql, (err, data)-> cb err, data 



  #完成某个issue，将会触发一系列操作，比如说发邮件等
  finishedIssue: (data, member_id, cb)->
    data.finish_time = Number(new Date())

    #找到并检查是否有owner，如果没有owner，则将owner设置为member_id
    self = @

    queue = []

    queue.push((done)->
      self.findById data.id, (err, result)->
        return err if err
        #没有找到id
        return cb null, result if not result
        data.owner = member_id if not result.owner
        #保存数据
        self.save data, (err,res)->
          done err, result.issue_id
    )

    queue.push(
      (issue_id, done)->
        sql = "SELECT COUNT(*) AS unfinished FROM issue_split WHERE

          issue_id=#{issue_id} AND status<>'done'"

        self.execute sql, (err, data)->
          done err, data[0].unfinished, issue_id

    )

    queue.push(
      (unfinished, issue_id, done)->
        return done null if unfinished isnt 0

        _issueEntity.save {id:issue_id, status:'done'}, (err,result)->
          done err, result
    )

    _async.waterfall queue,(err, result)->
      cb err, result


module.exports = new IssueSplit