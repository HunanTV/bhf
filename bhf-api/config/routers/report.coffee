module.exports = [
  {
    path: 'report/project/issue-finish'
    suffix: false
    biz: 'report'
    methods: get: 'projectIssueFinishStat', put: 0, post: 0, path: 0, delete: 0, patch: 0
  }

  {
    path: 'report/member/issue-finish'
    suffix: false
    biz: 'report'
    methods: get: 'memberIssueFinishStat', put: 0, post: 0, path: 0, delete: 0, patch: 0
  }

  {
    path: 'report/team/:team_id(\\d+)/issue-finish'
    suffix: false
    biz: 'report'
    methods: get: 'teamIssueFinishStat', put: 0, post: 0, path: 0, delete: 0, patch: 0
  }

  {
    path: 'report/weekly'
    suffix: false
    biz: 'report'
    methods: get: 'weeklyOfTeam', put: 0, post: 0, path: 0, delete: 0, patch: 0
  }
  {
    path: 'report/:team_id(\\d+)/weekly'
    suffix: false
    biz: 'report'
    methods: get: 'weeklyOfTeam', put: 0, post: 0, path: 0, delete: 0, patch: 0
    anonymity: ['get']
  }
  {
    #获取issue的报表，按用户分组
    path: 'report/issue'
    biz: 'issue'
    methods: get: 'report', post: 0, delete: 0, patch: 0, put: 0
  }
  {
    #获取issue的报表，按用户分组
    path: 'report'
    biz: 'report'
  }
]