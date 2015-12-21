###
  成员
###
_common = require '../common'
_entity = require '../entity'
_async = require 'async'
_path = require 'path'
_fs = require 'fs-extra'
_http = require('bijou').http
_notifier = require '../notification'
_realtime = require '../notification/realtime'
_mailer = require '../notification/mailer'
_cache = require '../cache'
_request = require 'request'

weixinMember = require('notification-center-sdk').WeixinMember

#用户注册时要刷新缓存
refreshMemberCache = (member_id, project_id)->
  #加载此用户的缓存信息
  _cache.member.load member_id, (err)->

  return if not project_id

  #重建项目成员的缓存
  _cache.projectMember.loadMemberOfProject project_id
  #重建用户有哪些项目
  _cache.projectMember.loadProjectOfMember member_id

#用户登录
signIn = (account, password, cb)->
  error406 = _http.notAcceptableError "用户名或者密码错误"
  return cb error406 if not account or not password
  _entity.member.signIn account, password, (err, member)->
    return cb err if err
    return cb error406 if not member
    return cb err, member

#绑定Open ID
bindOpenid = (member_id, token, cb)->
  queue = []
  queue.push(
    (done)->
      _request _common.formatString(_common.config.openid, token), (err, response, result)-> 
        err = new Error "Open ID验证服务器出错" if not (err || response.statusCode is 200)
        return done err if err

        result = JSON.parse result
        data =
          id: member_id 
          open_id: result.id
          gitlab_username: result.username
          gitlab_token: result.gittoken
        done err, result, data       
  )

  #检测realname和email是否存在，不存在则将gitlab的realname和email带入
  queue.push(
    (detail, data, done)->
      cond = id: data.id
      _entity.member.findOne cond, (err, member)->
        data.realname = detail.realname if !member.realname
        data.email = detail.email if !member.email
        done err, data
  )
  #保存数据
  queue.push(
    (data, done)-> _entity.member.save data, (err)-> done err
  )

  _async.waterfall queue, (err)-> cb err


#检测用户gitlab-token
exports.checkGitToken = (req, res, cb)->
  token = req.query.token
  queue = []
  #获取gitlab用户的详细信息
  queue.push(
    (done)->
      _request _common.formatString(_common.config.openid, token), (err, response, result)-> 
        err = new Error "Open ID验证服务器出错" if not (err || response.statusCode is 200)
        return done err if err

        result = JSON.parse result if result
        done err, result       
  )
      
  #检查openid是否绑定bhf账户
  queue.push(
    (detail, done)->
      cond = open_id: detail.id
      _entity.member.findOne cond, (err, member)-> done err, member
  )

  _async.waterfall queue, (err, member)->
    return _http.responseError err, res if err

    url = "/"
    #找到成员则写入session，否则更改跳转的url
    if member then exports.setSession req, member else url += "login?openid_token=#{token}"
    res.writeHead 302, Location: url
    res.end()

#保存微信
exports.saveWeixin = (req, res, cb)->
  userid = req.session.member_id
  weixin = req.body.weixin
  name = req.session.username or req.session.realname
  return cb _http.notAcceptableError "微信账号不正确" if not weixin
  queue = []
  queue.push((done)->
    _entity.member.findById userid, (err, member)->
      return done(err or _http.notAcceptableError("用户不存在")) if not member

      #微信一致
      return done(_http.notAcceptableError('微信号已保存'))  if member.weixin is weixin

      done(err, member.weixin, weixin)
  )

  #创建并删除旧的微信关系
  queue.push((oldWeixin, newWeixin, done)->

    #删除老的微信号
    #weixinMember.delete(oldWeixin) if oldWeixin

    #添加新微信号
    weixinMember.create({
        userid: newWeixin
        weixinid: newWeixin
        name: name
      }, (error)-> done(error)
    )
  )

  #修改数据库
  queue.push((done)->
    _entity.member.save {id: userid, weixin: weixin}, (err)-> done err
  )

  _async.waterfall queue, (error)->
    return _http.responseError error, res if error

    refreshMemberCache userid
    _http.responseJSON error, {}, res


#重置密码
exports.resetPassword = (client, cb)->
  account = client.query.account
  return cb _http.notAcceptableError "请输入您的帐号或者E-mail" if not account

  queue = []
  #检查用户名是否存在
  queue.push(
    (done)->
      _entity.member.findMemberByAccount account, (err, result)->
        err = _http.notAcceptableError "没有找到您的帐号[#{account}]" if not (err || result)
        done err, result
  )

  #重置密码
  queue.push(
    (member, done)->
      #根据时间生成一个8位数的密码
      password = _common.md5(new Date().toString()).substr(0, 8)
      data = password: _common.md5(password)

      _entity.member.updateById member.id, data, (err)-> done err, password, member.email
  )

  _async.waterfall queue, (err, password, email)->
    cb err, email: email
    return if err

    #向用户发送邮件
    subject = "您的密码已经重置成功"
    body = "您的新密码为：#{password}"
    _mailer.addTask email, subject, body

#修改密码
exports.changePassword = (client, cb)->
  old_password = client.body.old_password
  new_password = client.body.new_password
  error406 = _http.notAcceptableError "您的旧密码输入有误"
  return cb error406 if not old_password

  old_password = _common.md5(old_password)
  _entity.member.findById client.member.member_id, (err, member)->
    #发生错误，或者找不到用户，或者旧密码错误
    return cb(err || error406) if err or not member or old_password isnt member.password
    data = id: member.id, password: _common.md5(new_password)
    _entity.member.save data, cb

#修改用户权限
exports.changeRole = (client, cb)->
  #只有系统管理员才能修改用户的权限
  return cb _http.forbiddenError() if client.member.role isnt 'a'
  data =
    id: parseInt client.params.id
    role: _common.memberRoleValidator client.body.role

  #用户禁止修改自己的权限
  return cb _http.notAcceptableError '你不能修改自己的权限' if client.member.member_id == data.id
  #return cb(new _common.Error406('用户权限只能是a或者u')) if data.role isnt ['a', 'u']
  _entity.member.save data, cb

#请求token
exports.requestToken = (req, res, next)->
  #请求登录
  signIn req.body.account, req.body.password, (err, member)->
    return _http.responseError err, res if err
    #请求一个token，并返回给用户
    _entity.token.requestToken member.id, member.role, (err, token)->
      result =
        token: token
        member_id: member.id
        realname: member.realname
        role: member.role

      _http.responseJSON err, result, res

#设置用户的会话，包括session和cookies
exports.setSession = (req, member)->
  req.session.member_id = member.id
  req.session.role = member.role
  req.session.username = member.username
  req.session.email = member.email
  req.session.gitlab_token = member.gitlab_token

#用户登录模块
exports.signIn = (req, res, next)->
  queue = []
  queue.push(
    (done)->
      signIn req.body.account, req.body.password, (err, member)-> done err, member
  )

  #绑定open id
  queue.push(
    (member, done)->
      return done null, member if not req.body.openid_token

      bindOpenid member.id, req.body.openid_token, (err)-> done err,member
  )


  _async.waterfall queue, (err, member)->
    return _http.responseError err, res if err
    exports.setSession req, member

    #有安全问题，内网不做考虑
    if req.body.remember
      oneYear = 365 * 24 * 60 * 60 * 1000
      res.cookie 'remember', true, maxAge: oneYear, httpOnly: true
      res.cookie 'member_id', member.id, maxAge: oneYear, httpOnly: true

    #返回
    result = member_id: member.id, role: member.role, username: member.username
    _http.responseJSON err, result, res
         
   

#添加用户
exports.addMember = (client, cb)->
  member_id = null
  tokenData = null
  token = client.body.token

  data =
    username: client.body.username
    password: client.body.password
    realname: client.body.realname
    email: client.body.email
    #如果用户已经登录，则
    status: if client.member.isLogin then 'normal' else 'new'
    role: 'u'    #默认用户权限用户

  return cb _http.notAcceptableError '您的密码设置不正确' if not data.password or data.password.length < 4
  return cb _http.notAcceptableError '您的邮箱输入不正确' if not data.email

  #A允许指定用户的role
  data.role = client.body.role if client.member.role is 'a'
  data.role = _common.memberRoleValidator(data.role)

  queue = []

  #非登录的用户，必需使用token才可以创建用户
  queue.push(
    (done)->
      #已登录用户添加其它用户，不需要校验token
      return done null if client.member.isLogin
      return done _http.notAcceptableError('您需要BHF的邀请码才能注册') if not token

      cond = token : token, status: 'new'
      _entity.invite.findOne cond, (err, result)->
        return err if err
        tokenData = result
        err = _http.notAcceptableError('邀请码无效或者已被使用') if token isnt result?.token
        done err
  )


  #检测用户名是否已经存在
  queue.push(
    (done)->
      return done null if not data.username
      _entity.member.exists username: data.username, (err, exists)->
        err = _http.notAcceptableError("用户名#{data.username}已经存在") if exists
        done err
  )

  #检测邮箱是否已经存在
  queue.push(
    (done)->
      _entity.member.exists email: data.email, (err, exists)->
        err = _http.notAcceptableError("邮箱#{data.email}已经存在")  if exists
        done err
  )

  #注册用户
  queue.push(
    (done)->
      data.password = _common.md5 data.password
      _entity.member.save data, (err, id)->
        member_id = id
        done err
  )

  #注册成功后，如果用户使用了邀请码注册，则为将用户添加到项目中
  queue.push(
    (done)->
      return done null if not tokenData or not tokenData.project_id

      #加入用户到项目
      _entity.project_member.addMembers tokenData.project_id, [member_id], (err)->
        done err
  )

  #将token设置为已经使用
  queue.push(
    (done)->
      return done null if not tokenData
      updateData =
        id: tokenData.id
        status: 'used'
        member_id: member_id
        used_time: new Date().getTime()
      _entity.invite.save updateData, (err)-> done null
  )

  ###
  #用户注册的时候，暂时不保存git列表
  #保存用户的git列表
  queue.push(
    (id, done)->
      member_id = id
      gits = client.body.gits
      gits = [gits] if not (gits instanceof Array)
      return done null, id if gits.length is 0

      _entity.git_map.saveGits member_id, 'member', gits, (err)->
        done err

  )
  ###

  _async.waterfall queue, (err)->
    return cb err if err

    cb err, id: member_id

    #刷新新注册用户的缓存信息
    refreshMemberCache member_id, tokenData?.project_id

    #给用户发送邮件推到邮件列表中
    _notifier.welcome data.email, data.realname

#获取当前用户
exports.currentMember = (req, res, cb)->
  res.json
    member_id: req.session.member_id
    username: req.session.username
    role: req.session.role

#获取用户列表
exports.allMember = (client, cb)->
  options =
    fields: ['id', 'username', 'realname', 'role', 'email']
    pagination: _entity.member.pagination client.query.pageIndex, client.query.pageSize

  _entity.member.find null, options, cb

#获取用户的所有资料
exports.profile = (client, cb)->
  #允许查询其他用户的profile
  member_id = client.query.member_id || client.member.member_id
  fields = ['realname', 'username', 'email', 'role', 'gitlab_token', 'notification']
  _entity.member.findById member_id, fields, (err, member)->
    return cb err if err or not member

    _entity.git_map.findMemberGits member_id, (err, gits)->
      member.gits = gits
      cb err, member

#保存用户的资料
exports.saveProfile = (client, cb)->
  data =
    username: client.body.username
    realname: client.body.realname
    email: client.body.email
    id: client.member.member_id
    gitlab_token: client.body.gitlab_token
    notification: client.body.notification

  queue = []
  #检测username是否存在
  queue.push(
    (done)->
      _entity.member.exists username: data.username, {}, id: data.id, (err, exists)->
        err = _http.notAcceptableError("您的用户名#{data.username}已经存在") if exists
        done err
  )

  #检测email是否存在
  queue.push(
    (done)->
      _entity.member.exists email: data.email, {}, id: data.id, (err, exists)->
        err = _http.notAcceptableError("您的邮箱#{data.email}已经存在") if exists
        done err
  )

  #保存数据
  queue.push(
    (done)-> _entity.member.save data, (err)-> done err
  )

  #保存gits
  queue.push(
    (done)->
      gits = client.body.gits
      gits = [gits] if not (gits instanceof Array)
      _entity.git_map.saveGits data.id, 'member', gits, done
  )

  _async.waterfall queue, (err)->
    cb err

    #更新成员缓存
    refreshMemberCache data.id
    #更新git的缓存
    _cache.gitMap.load()

#退出
exports.signOut = (req, res, next)->
  #删除session
  _realtime.offline req.session.member_id
  delete req.session.member_id
  delete req.session.role
  res.clearCookie 'remember'
  res.clearCookie 'member_id'
  res.end()

#获取用户的头像
exports.getAvatar = (req, res, next, client)->
  member_id = req.params.member_id || client.member.member_id || 'default'
  storage = _common.config.storage
  file = _path.join storage.base, storage.avatar, member_id + '.png'

  if _fs.existsSync file
    res.sendfile file
  else
    #查找用户的邮箱
    _entity.member.findById member_id, (err, member)->
      return _http.responseNotFound res if err or not member

      md5 = _common.md5(member.email || 'default')
      url = "http://www.gravatar.com/avatar/#{md5}?s=90&d=identicon"
      res.writeHead 301, Location: url
      res.end()

#向指定用户发邮件
exports.mailTo = (client, cb)->
  subject = client.body.subject
  body = client.body.content
  receive_project = client.body.receive_project

  return cb _http.forbiddenError() if not /a/i.test client.member.role
  cb null

  #向所有人发送消息
  _mailer.mailToAll receive_project, client.member.member_id, subject, body


#注册用户的设备
exports.registerDevice = (client, cb)->
    data = client.body
    return cb null if not (data.device_id and data.type)

    data.member_id = client.member.member_id
    data.timestamp = new Date().valueOf()

    cond =
      member_id: data.member_id
      device_id: data.device_id

    #先要检查同样的设备是否已经存在
    _entity.member_device.exists cond, (err, exists)->
      return cb err if err or exists

      _entity.member_device.save data, (err)-> cb err, {}

#移除用户注册的设备
exports.removeDevice = (client, cb)->
  cond =
    member_id: client.member.member_id
    device_type: client.query.device_type
    device_id: client.query.device_id

  _entity.member_device.remove cond, (err)-> cb err, {}

#获取用户的设备列表
exports.getDevice = (client, cb)->
  cond =
    member_id: client.member.member_id

  _entity.member_device.find cond, cb

exports.toString = -> _path.basename __filename
