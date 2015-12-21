exports.schema =
  name: "invite"
  fields:
    #创建者
    creator: 'integer'
    #指定邮箱
    email: ""
    #过期时间
    expire: "bigInteger"
    #邀请码
    token: ""
    #指定项目id，当用户用这个邀请码注册后，就会自动加入到这个项目中
    project_id: 'integer'
    #默认状态
    status: ''
    #已经使用的用户
    member_id: 'integer'
    #创建时间
    timestamp: 'bigInteger'
    #使用时间
    used_time: 'bigInteger'