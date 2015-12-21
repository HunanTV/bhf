###
  路由规则
    {
      #paths优先，比path的优先级高
      paths: {
        #如果没有指定具体的curd，则会使用all这个路由
        all: '#{rootAPI}someURL'
        #这个会优先于all
        get: '/asset/:project_id(\\d+)/:filename'
      },
      #指定一个path，这个和paths是互斥的
      path: 'commit'
      #用于指定将要处理的业务逻辑文件，对应biz文件夹下的具体文件
      biz: 'commit'
      #指定允许匿名的方法
      anonymity: ['post']
      #为删除指定方法，则put/get将不会被处理，如果是用{}包裹起来，则会传递req,res
      methods: delete: 'deleteMethod', put: false, get: '{getMethod}'
    },
###

module.exports = [].concat(
  require('./routers/member'),
  require('./routers/issue'),
  require('./routers/project'),
  require('./routers/report'),
  require('./routers/other')
)

#  {
#  #用户登录注册
#    path: 'mine'
#    suffix: false
#    biz: 'member'
#    methods:  post: 'addMember', put: '{signIn}', delete: '{signOut}', get: '{currentMember}', patch: 0
#    anonymity: ['post', 'put']
#  },


#  {
#    #获取项目状态，及修改项目状态的路由
#    path: 'project/:project_id/status'
#    biz: 'project'
#    suffix: false
#    methods: get: 'getStatus', put: 'changeStatus', post: 0, delete: 0, patch: 0
#  },
#  {
#    #发布项目
#    path: 'project/:project_id/deploy'
#    biz: 'project'
#    suffix: false
#    methods: post: '{deploy}', get: 0, delete: 0, patch: 0, put: 0
#  },
#  {
#  #提交commit，用于git或svn提交commit时，自动获取commit并分析
#    path: 'project/:project_id(\\d+)/git/tags'
#    biz: 'gitlab'
#    suffix: false
#    methods: get: 'getTags', post: 0, delete: 0, patch: 0, put: 0
#  },
#  {
#  #更改issue的状态，仅能更新
#    path: 'project/:project_id/issue/:issue_id/status'
#    biz: 'issue'
#    suffix: false
#    methods: get: 0, delete: 0,  post: 0, patch: 0, put: 'changeStatus'
#  },
#  {
#    #更改issue的标签，仅支持更新
#    path: 'project/:project_id/issue/:issue_id/tag'
#    biz: 'issue'
#    suffix: false
#    methods: get: 0, delete: 0,  post: 0, patch: 0, put: 'changeTag'
#  },
#  {
#    #更改issue的状态，仅能更新
#    path: 'project/:project_id/issue/:issue_id/priority'
#    biz: 'issue'
#    suffix: false
#    methods: get: 0, delete: 0,  post: 0, put: 'changePriority'
#  },

  ##========================报表相关========================
