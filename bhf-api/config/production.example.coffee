#TODO !!! 去除敏感信息
module.exports =
  database:
    client: 'mysql',
    connection:
      host     : 'localhost',
      user     : 'root',
      password : '123456',
      database : 'bhf'
  redis:
    server: 'localhost'
    port: 6379
    database: 0
    unique: 'bhf-xxx'

  deploy:
    host: 'localhost'
    port: 9001
    path: '/release'

  #git的地址
  gitlab:
    hooks: "http://xxxxx" #gitlab webhooks地址
    url: 'http://git.xxxx.com' #内网gitlab地址
    token: 'xxxxxx' #gitlab token
    api: 'http://git.xxx.com/api/v3' #内网gitlab接口地址
    database:
      host     : 'localhost', #内网gitlab数据库配置
      user     : 'gitlab',
      password : 'gitlab',
      database : 'gitlabhq'

  #数据存储的位置
  storage:
    #需要读这个变量 NBE_PERMDIR
    base: './storage'
    avatar: 'avatar'
    assets: 'assets'
    uploads: 'uploads'
    uploadTemporary: 'uploadTemporary'

  notification:
    email: true
    weixin: true
    client: true
    webhook: true

  rootAPI: '/api/'
  port: 8001
  #是否允许用户注册
  allowRegister: true
  thumbnail: width: 100, height: 80
  host: 'http://bhf.hunantv.com/'