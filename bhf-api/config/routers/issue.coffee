module.exports = [
  {
  #查看某个issue下的所有commit
    path: 'project/:project_id/issue/:issue_id(\\d+)/commit'
    biz: 'commit'
    methods: post: 0, delete: 0, patch: 0, put: 0
  },
  {
  #查看某个issue下的所有log
    path: 'project/:project_id/issue/:issue_id(\\d+)/log'
    biz: 'log'
    methods: get: 'getLogWithIssue', post: 0, delete: 0, patch: 0, put: 0
  },
  {
  #素材，上传素材以及读取素材数据库中的记录，没有指定issue.id
    path: 'project/:project_id/issue/:issue_id(\\d+)/assets'
    biz: 'asset'
    methods: post: '{uploadFile}', delete: 'remove', patch: 0, put: 0
  },
  {
  #上传docx直接生成issues
    path: 'project/:project_id(\\d+)/:version_id(\\d+)/:category_id(\\d+)/issue/create/assets'
    biz: 'asset'
    methods: post: '{splitDocToIssue}', delete: 0, patch: 0, put: 0,get: 0
  },
  {
  #issue相关
    path: 'project/:project_id/issue'
    biz: 'issue'
    methods: post: 'createIssue', put: 'updateIssue', delete: 0, patch: 0, get: 'getIssue'
  },
  {
  #issue相关
    path: 'project/:project_id/issue/:issue_id(\\d+)/split'
    biz: 'issue_split'
  },
  {
  #针对issue的评论
    path: 'project/:project_id/issue/:issue_id(\\d+)/comment'
    biz: 'comment'
  },
  {
  #issue关注
    path: 'project/:project_id/issue/:issue_id(\\d+)/follow'
    suffix: false
    biz: 'issue_follow'
  },
  {
    #获取测试任务的测试
    path: 'project/:project_id/issue/stat/test'
    biz: 'issue'
    methods: post: 0, delete: 0, patch: 0, put: 0, get: 'statTestIssue'
  }
]