module.exports = [
  {
    path: 'apis'
    suffix: false
    biz: 'apis'
    anonymity: ['get']
    methods: put: 0, delete: 0, post: 0, patch: 0
  }
  {
  #提交commit，用于git或svn提交commit时，自动获取commit并分析
    path: 'git/commit'
    biz: 'commit'
    suffix: false
    anonymity: ['post']
    methods: post: 'postCommit', get: 0, delete: 0, patch: 0, put: 0
  },
  {
  #导入commits信息
    path: 'commit/import'
    biz: 'commit'
    methods: get: 'import', post: 0, delete: 0, patch: 0, put: 0
  },

  {
    #用户的消息
    path: 'message'
    biz: 'notification'
    methods:  post: 0, put: 'readMessage', delete: 0, patch: 0, get: 'getMessage'
  }

  {
    #动态流
    path: 'stream'
    biz: 'notification'
    methods:  post: 0, put: 0, delete: 0, patch: 0, get: 'readStream'
  }

  {
    #动态流
    path: 'stream/daily'
    biz: 'notification'
    methods:  post: 0, put: 0, delete: 0, patch: 0, get: 'readDailyStream'
  }
]