_ = require 'lodash'
_async = require 'async'

#转换报表格式，查询出来的数据是按项目，转换为按人
class reportConverter
  constructor: (@projects, @reports)->
    @members = {}
    @analysisProject(project) for project in @projects
#    return @members
    return @groupMember()

  #分析issue
  analysisMemberIssue: (memberData)->
    member = @getMemberNode memberData
    for issue in memberData.issue
      #状态必需是new/done/doing才会进入报表
      continue if not (issue.status in ['new', 'done', 'doing'])
      key = if issue.status is 'done' then 'finished' else 'unfinished'
      member[key].push issue

  #分析项目
  analysisProject: (project)->
    @analysisMemberIssue memberIssue for memberIssue in project.report.assigned

  #合并有任务和没任务的用户
  groupMember: ()->
    result =
      finished: []
      unfinished: []
      lazybones: []
    for member_id, member of @members
      others = ""
      others = report.content for report in @reports when parseInt(report.member_id) is parseInt(member_id)

      if member.unfinished.length > 0
        result.unfinished.push(
          member: member.member
          issue: member.unfinished
      )

      if member.finished.length > 0 || others
        finished = 
          member: member.member
        finished.issue = member.finished if member.finished.length > 0
        finished.others = others.split('\n') if others
        result.finished.push finished


      if member.unfinished.length is 0 and member.finished.length is 0 and !others
        result.lazybones.push member.member

    result

  #根据member_id获取成员的节点，如果不存在，则创建一个
  getMemberNode: (memberData)->
    if not @members[memberData.member_id]
#      console.log memberData
      @members[memberData.member_id] =
        member:
          realname: memberData.realname
          member_id: memberData.member_id
          username: memberData.username
          role: memberData.role
          email: memberData.email
        unfinished: []
        finished: []

    @members[memberData.member_id]



module.exports = reportConverter