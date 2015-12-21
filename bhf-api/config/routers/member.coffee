module.exports = [
  {
  	path: 'team'
  }
  {
    path: 'team/:team_id(\\d+)/member'
    biz: 'team'
    methods: delete: 'removeMember', put: 'editMember', post: 'addMember', get: 'getMembers'
  }

  {
#更改密码
    path: 'account/change-password'
    suffix: false
    biz: 'member'
    methods: post: 0, put: 'changePassword', delete: 0, get: 0, patch: 0
  }
  {
#重置密码
    path: 'account/reset-password'
    suffix: false
    biz: 'member'
    methods: post: 0, put: 0, delete: 0, get: 'resetPassword', patch: 0
    anonymity: ['get']
  }
  {
    #绑定微信
    path: 'account/weixin'
    suffix: false
    biz: 'member'
    methods: post: '{saveWeixin}', put: 0, delete: 0, get: 0, patch: 0
  }
#  {
#  #更改角色
#    path: 'member/role'
#    biz: 'member'
#    methods: post: 0, put: 'changeRole', delete: 0, get: 0, patch: 0
#  }
  {
#请求用户的tokey
    path: 'account/token'
    suffix: false
    biz: 'member'
    methods:  post: '{requestToken}', put: 0, delete: 0, get: 0, patch: 0
    anonymity: ['post', 'put']
  }
  {
#用于获取用户的信息，一般用于管理或者用户的profile
    path: 'member'
    biz: 'member'
    anonymity: ['post']
    methods: get: 'allMember', put: 0, delete: 0, post: 'addMember', patch: 0
  }
#  {
#    #用户发送邮件通知
#    path: 'member/mail'
#    biz: 'member'
#    methods: get: 0, put: 0, delete: 0, post: 'mailTo', patch: 0
#  }
  {
#用于获取用户的信息，一般用于管理或者用户的profile
    path: 'account/profile'
    suffix: false
    biz: 'member'
    methods: get: 'profile', put: 'saveProfile', delete: 0, post: 0, patch: 0
  }
  {
#用于获取用户的信息，一般用于管理或者用户的profile
    path: 'account/avatar/:member_id(\\d+)?'
    suffix: false
    biz: 'member'
    anonymity: ['get']
    methods: get: '{getAvatar}', put: 0, delete: 0, post: 0, patch: 0
  }

  {
#用户登录注册s
    path: 'session'
    suffix: false
    biz: 'member'
    methods:  post: '{signIn}', put: 0, delete: '{signOut}', get: '{currentMember}', patch: 0
    anonymity: ['post', 'delete']
  }

  {
#查询用户的git地址
    path: 'member/git-map'
    biz: 'git_map'
    data: type: 'member'
    methods: post: 0, put: 0, delete: 0
  }

  {
#查询openid的token
    path: 'member/git-token'
    biz: 'member'
    data: type: 'member'
    methods: post: 0, put: 0, delete: 0, get: '{checkGitToken}'
    anonymity: ['get']
  }

  {
#处理用户的设备
    path: 'account/device'
    biz: 'member'
    suffix: false
    methods: post: 'registerDevice', put: 0, delete: 'removeDevice', get: 'getDevice'
  }
]