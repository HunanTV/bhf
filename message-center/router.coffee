###
  路由配置
###

path = require 'path'
module.exports =
  cwd: path.join __dirname, 'biz'
  baseUrl: '/api'
  map: [
    {
      path: '/token'
      biz: 'login'
      methods: PUT: false, GET: false, DELETE: false, POST: 'getToken'
    }
    {
      path: '/user'
      biz: 'user'
    }
    {
      path: '/message/:type'
      biz: "message"
    }
  ]

  #不需要 token验证的 API接口
  no_authentication: [
    {
      path: "/user"
      methods: ['POST'] #注册
    }
    {
      path: "/token"
      methods: ['POST'] #登陆
    }
  ]