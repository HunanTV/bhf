###
  报表
###
_entity = require '../entity'
_common = require '../common'
_ = require 'lodash'
_async = require 'async'
_http = require('bijou').http
_notifier = require '../notification'
_moment = require 'moment'
_converter = require './report_converter'

##将按项目的报表，转换生成为按用户的报表
#projectToMemberReport = (projects)->
#  members = {}
#
#  #将项目中的
#  pushToFinished = (data)->
#    for memberTask in data
#      if not (member = members[memberTask.member_id])
#        member = members[memberTask.member_id] =
#
#  pushToFinished(project.report.assigned) for project in projects

#指定时间段，所有项目的issue完成量的统计
exports.projectIssueFinishStat = (client, cb)->
  startTime = client.query.startTime
  endTime = client.query.endTime
  _entity.report.projectIssue startTime, endTime, cb

exports.memberIssueFinishStat = (client, cb)->
  startTime = client.query.startTime
  endTime = client.query.endTime
  _entity.report.memberIssue startTime, endTime, cb

exports.teamIssueFinishStat = (client, cb)->
  team_id = client.params.team_id
  startTime = client.query.startTime
  endTime = client.query.endTime
  _entity.report.teamIssue team_id, startTime, endTime, cb

#获取团队周报，目前获取用户所担任Leader的项目周报报
# exports.weeklyOfTeam = (client, cb)->
#   #查询报表的条件
#   cond =
#     all: true
#     member_id: client.member.member_id
#     project_id: client.query.project_id
#     start_time: Number(client.query.start_time)
#     end_time: Number(client.query.end_time)

#   cond.start_time = _moment().startOf('week').valueOf() if isNaN(cond.start_time)
#   cond.end_time = _moment().endOf('week').valueOf() if isNaN(cond.end_time)

#   projects = 
#     items: [
#       {
#         report: {}  
#       }
#     ]
#   # queue = []


#   # #第一步，获取用户担任leader的项目
#   # queue.push(
#   #   (done)->
#   #     pagination = _entity.issue.pagination 1, 9999
#   #     _entity.project.fetch cond, pagination, (err, result)->
#   #       projects = result
#   #       done err
#   # )

#   # #分别获取每一个项目的报表
#   # queue.push(
#   #   (done)->
#   #     index = 0
#   #     _async.whilst(
#   #       -> index < projects.items.length
#   #       (innerDone)->
#   #         project = projects.items[index++]
#   #         condition = _.extend(project_id: project.id, cond)
#   #         _entity.issue.report condition, (err, result)->
#   #           project.report = result
#   #           innerDone err
#   #       done
#   #     )
#   # )

#   _entity.issue.report cond, (err, result)->
#     projects.items[0].report = result
#     cb err, new _converter(projects.items)





#根据团队Id获取团队周报
exports.weeklyOfTeam = (client, cb)->
  #查询报表的条件
  cond =
    member_id: client.member.member_id
    start_time: Number(client.query.start_time)
    end_time: Number(client.query.end_time)

  cond.start_time = _moment().startOf('week').valueOf() if isNaN(cond.start_time)
  cond.end_time = _moment().endOf('week').valueOf() if isNaN(cond.end_time)
  cond.team_id = client.params.team_id if client.params.team_id
  cond.project_id = client.query.project_id if client.query.project_id
  cond.all = true if client.query.project_id

  projects = 
    items: [
      {
        report: {}  
      }
    ]

  queue = []
  queue.push(
    (done)->
      _entity.issue.report cond, (err, result)->
        projects.items[0].report = result
        done err
  )

  queue.push(
    (done)->
       _entity.report.find {time: cond.start_time}, (err, result)->
        done err, result
  )


  _async.waterfall queue, (err, result)->
    cb err, new _converter(projects.items, result)

  # _entity.issue.report cond, (err, result)->
  #   projects.items[0].report = result
  #   cb err, new _converter(projects.items)



exports.save = (client, cb)->
  cond = client.body
  cond.member_id = client.member.member_id
  _entity.report.save cond, (err, result)->
    cb err,result


exports.get = (client, cb)->
  cond = 
    member_id: client.member.member_id
    time: client.query.time
  _entity.report.findOne cond, (err,result)->
    cb err,result
  



exports.toString = -> 'biz.report'