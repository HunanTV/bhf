###
  author: huyinghuan
  date: 2015-07-03
###
_mysql = require 'mysql'
_async = require 'async'
_http = require('bijou').http
_GitLabInterface = require 'gitlab-few'
_entity = require '../entity'
_cache = require '../cache'
_enume = require('../common').enumerate
_config = require('../common').config
_database_config = _config.gitlab.database

connection = _mysql.createConnection(_database_config)

exports.fork = (client, cb)->
  project_id = client.params.project_id
  be_forked_git_id = client.params.gitlab_id
  member_id =  client.member.member_id

  queue = []
  gitlab = null
  #初始化gitlab接口
  queue.push((done)->
    gitlab_token = _cache.member.get(member_id).gitlab_token
    gitlab = new _GitLabInterface(gitlab_token, _config.gitlab.api)
    done(null)
  )

  #fork项目
  queue.push((done)->
    gitlab.projects().fork(be_forked_git_id).then((data)->
      done(null, data.id, data.ssh_url_to_repo)
    )
    .catch((err)->
      console.error err
      done({msg: "Fork失败,请查看项目权限或是否已存在自己的仓库"})
    )
  )


  #保存git到项目
  queue.push((git_id, git_url, done)->
    project =
      type: _enume.gitMapType.project
      target_id: project_id
      git: git_url
      git_id: git_id

    _entity.git_map.save(project, (err)->
      return done({msg: "gits关联项目失败"}) if err
      done(null, git_id)
    )
  )

  #插入hooks
  queue.push((git_id, done)->
    gitlab.projects(git_id).hooks().post(_config.gitlab.hooks)
      .then(()->
        done(null)
      )
      .catch((err)->
        console.error err
        done({msg: "gits设置hooks失败"})
      )
  )

  _async.waterfall(queue, (error)->
    return cb() if not error

    if error.msg
      cb(_http.notAcceptableError(error.msg))
    else if error
      console.error error
      cb(error)
    else
      cb()
    _catch.git_map.load({type: _enume.gitMapType.project})
  )

###
  Author: ec.huyinghuan@gmail.com
  Date: 2015.07.09
  Describe:
    给项目添加关联一个已存在的gitlab地址
###
exports.addGitToProject = (client, cb)->
  project_id = client.params.project_id
  gitlab_url = client.body.gitlab_url
  member_id =  client.member.member_id

  return cb _http.notAcceptableError("gitlab的地址不能为空") if not gitlab_url

  queue = []
  gitlab = null

  #查询这个gitlab是否已经关联过
  queue.push((done)->
    _entity.git_map.find({git: gitlab_url}, (err, result)->
      #如果不存在
      return done(null, null) if not result.length
      done(null, result[0].target_id)
    )
  )

  #已存在的项目做友好提示
  queue.push((target_project_id, done)->
    return done() if not target_project_id
    if target_project_id is ~~project_id
      return done({msg: "gitlab地址不需要重复绑定！"})

    _entity.project.find({id: target_project_id}, (err, result)->
      title = result[0]?.title or "未知"
      done({msg: "该gitlab地址已被#{title}项目绑定！请先解除绑定或重新关联gitlab地址"})
    )
  )

  #初始化gitlab接口
  queue.push((done)->
    gitlab_token = _cache.member.get(member_id).gitlab_token
    gitlab = new _GitLabInterface(gitlab_token, _config.gitlab.api)
    done()
  )

  #获取gitlab id
  queue.push((done)->
    namespace = (gitlab_url.split(':')[1]).split('/')
    path = namespace[0]
    name = namespace[1].replace(/\.git$/, "")
    sql = "select p.id
      from projects p left join namespaces n
      on p.namespace_id = n.id
      where p.name = ? and n.path= ?
      limit 1"
    connection.query(sql, [name, path], (err, result)->
      return done({msg: "仓库不存在"}) if result.length is 0
      done(err, result[0].id)
    )

  )
  #查看hooks是否已经设置过了
  queue.push((git_id, done)->
    sql = "
      select id from web_hooks where project_id = ? and url = ?
    "
    connection.query(sql, [git_id, _config.gitlab.hooks], (err, result)->
      return done(err) if err
      done(null, git_id, result.length)
    )
  )

  #设置hooks
  queue.push((git_id, hooksCount, done)->
    #如果已经设置过了hooks，那么跳过
    return done(null, git_id) if hooksCount isnt 0
    gitlab.projects(git_id).hooks().post(_config.gitlab.hooks)
    .then(->
      done(null, git_id)
    )
    .catch((err)->
      done({msg: "gits设置hooks失败, 请检查是否具有该仓库权限！", err: err})
    )
  )

  #保存git到项目
  queue.push((git_id, done)->
    project =
      type: _enume.gitMapType.project
      target_id: project_id
      git: gitlab_url
      git_id: git_id

    _entity.git_map.save(project, (err)->
      return done({msg: "gits关联项目失败", err: err}) if err
      done(null)
    )
  )

  _async.waterfall(queue, (error)->
    return cb() if not error
    console.error error if error
    if error.msg
      cb _http.notAcceptableError(error.msg)
    else if error
      cb(error)
    else
      cb()
      _cache.gitMap.load({type: _enume.gitMapType.project})

  )


###
  Author: ec.huyinghuan@gmail.com
  Date: 2015.07.09 16:20 PM
  Describe:
    根据token和仓库名查询是否存在

  @params {string} 私人的gitlab的token
  @params {string} 需要查询的仓库名称
  @params {function} 回调函数
    接收两个参数function(err, exists){...}
      @params {Error}
      @params {boolean} 如果项目名称存在，则exists为true, 否则false
  @return {null}

###
exports.isExistsProjectInMyAccountByName = (token, name, cb)->
  sql = "
      select p.*
        from users u right join projects p
        on u.id = p.creator_id
        where u.authentication_token = ? and p.name = ?
    "
  connection.query(sql, [token, name], (err, result)->
    return cb(err) if err
    #存在
    if result.length
      cb(null, true)
    else
      cb(null, false)
  )

###
  Author:  ec@huyinghuan@gmail.com
  Date: 2015.07.16
  Describe: 在指定的gitlab列表中找到属于自己的gitlab列表
###
exports.getMyGitListInGiven = (auth_token, givenGitIdList, cb)->
  sql = "
    select p . *
    from users u right join projects p ON u.id = p.creator_id
    where u.authentication_token = ? and p.id in (?)
  "
  connection.query(sql, [auth_token, givenGitIdList], (err, result)->
    cb(err, result)
  )

###
  Author:  ec@huyinghuan@gmail.com
  Date: 2015.07.16
  Describe: 根据id获取namespace
###
exports.getNamespaceById = (id, cb)->
  sql = "
    select * from projects where id = ?
  "
  connection.query(sql, [id], (err, result)->
    return cb(err) if err
    return cb(null, false) if not result.length
    project = result[0]
    cb(null, "#{project.path}/#{project.name}")
  )
