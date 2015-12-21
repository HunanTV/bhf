_path = require 'path'
_async = require 'async'
_fs = require 'fs'
_MemberEntity = require('../biz/member')
_IssueEntity = require('../biz/issue')

importIssue = (issue, cb)->
  issue.project_id = 1
  queue = []
  queue.push(
    (done)->
      entity = new _MemberEntity(member_id: 0)
      cond = realname: switch issue.owner
        when 'Lian Hsueh' then '薛潋'
        when 'lanbin1987' then '兰斌'
        else issue.owner

      entity.find cond, (err, results)->
        member = results.items[0]
        issue.creator = issue.owner = if err or not member then 0 else member.id
        done null
  )

  queue.push(
    (done)->
      entity = new _IssueEntity(member_id: 0)
      entity.save issue, done
  )

  _async.series queue, cb

execute = ()->
  data = require './tower_mgoTV'
  index = 0
  _async.whilst(
    -> index < data.length
    (done)->
      console.log "正在导入第#{index}条"
      importIssue data[index++], done
    (err)-> console.log err || '导入完成'
  )


#execute()