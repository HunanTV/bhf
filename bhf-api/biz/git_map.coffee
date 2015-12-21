#    Author: 易晓峰
#    E-mail: wvv8oo@gmail.com
#    Date: 1/5/15 10:02 AM
#    Description:

_entity = require '../entity'
_entityMember = require '../entity/member'
_GitLabInterface = require 'gitlab-few'
_config = require('../common').config
_async = require 'async'
_http = require('bijou').http

_enume = require('../common').enumerate
_gitlab = require './gitlab'
_cache = require '../cache'
exports.get = (client, cb)->
  cond =
    git: client.query.git
    type: client.router.data.type
    target_id: client.query.target_id

  _entity.git_map.find cond, cb

###
  获取gits中分支信息
###
getBranchesByProjects = (gitlab, projects, cb)->
  rewriteProjects = []
  _async.whilst(()->
    return projects.length > 0
  , (done)->
    project = projects.pop()
    gitlab.projects(project.id).branches().getAllNames().then((data)->
      rewriteProjects.push({
        id: project.id
        default_branch: project.default_branch
        name: project.name
        branches: data
        path_with_namespace: "#{project.path}/#{project.name}"
      })
      done()
    )
  , (err)->
    cb(err, rewriteProjects)
  )

###
  获取项目中属于自己的git仓库地址列表
###
exports.getProjectOwnedGitsList = (client, cb)->
  project_id = client.params.project_id
  member_id =  client.member.member_id
  gitlab = null
  queue = []
  gitlab_token = _cache.member.get(member_id).gitlab_token
  gitlab = new _GitLabInterface(gitlab_token, _config.gitlab.api)


  #获取当前项目关联的所有gits地址
  queue.push(
    (done)->
      cond =
        type: client.router.data.type
        target_id: project_id

      _entity.git_map.find cond, (err, result)->
        return done(err) if err
        if not result.length
          err = _http.notAcceptableError("本项目没有设置gitlab关联")
          return done(err)

        gitArr = []
        gitArr.push item.git_id for item in result
        done(null, gitArr)
  )

  #获取当前项目中属于自己的gitlab地址
  queue.push((gitArray, done)->
    _gitlab.getMyGitListInGiven(gitlab_token, gitArray, (err, projectList)->
      return done(null, projectList) if not err
      console.error err
      done(_http.notAcceptableError("获取git列表失败"))
    )
  )

  #获取相关分支信息
  queue.push(
    (canBeImportCommitsGits, done)->
      if not canBeImportCommitsGits.length
        err = _http.notAcceptableError("当前项目中暂未绑定你的git仓库，请在项目设置中进行添加")
        return done(err)
      getBranchesByProjects(gitlab, canBeImportCommitsGits, cb)
  )

  _async.waterfall(queue, (err, result)->
    cb err, result
  )

###
  Author: ec.huyignhuan@gmail.com
  Date: 2015.07.06
  Describe: 获取项目相关的所有git地址
###
exports.getAllGitsInProject = (client,cb)->
  project_id = client.params.project_id
  cond =
    type: client.router.data.type
    target_id: project_id

  _entity.git_map.find cond, cb

###
  Author: ec.huyignhuan@gmail.com
  Date: 2015.07.07 15:50 PM
  Describe: 删除git_map里面一条记录
###
exports.delOne = (client, cb)->
  id = client.params.id
  _entity.git_map.removeById id, cb

###
  Author: ec.huyinghuan@gmail.com
  Date: 2015.07.08 11:00 AM
  Describe: 根据一个git id fork项目，并设置webhooks和关联项目
###
exports.fork = (client, cb)-> _gitlab.fork(client, cb)

###
  Author: ec.huyinghuan@gmail.com
  Date: 2015.07.09 11:20 AM
  Describe: 给项目添加关联一个已存在的gitlab地址
###
exports.addGitToProject = (client, cb)-> _gitlab.addGitToProject(client, cb)

###
  Author: ec.huyinghuan@gmail.com
  Date: 2015.07.09 15:30 PM
  Describe: 创建一个新的仓库并关联到项目
###
exports.createGitForProject = (client, cb)->
  project_id = client.params.project_id
  gitlab_name = client.body.gitlab_name
  member_id =  client.member.member_id
  return cb _http.notAcceptableError("gitlab的名字不能为空") if not gitlab_name
  queue = []
  gitlab = null
  gitlab_token = _cache.member.get(member_id).gitlab_token
  #初始化gitlab接口
  queue.push((done)->
    gitlab = new _GitLabInterface(gitlab_token, _config.gitlab.api)
    done()
  )

  #检查项目是否存在
  queue.push((done)->
    _gitlab.isExistsProjectInMyAccountByName(gitlab_token, gitlab_name,
      (err, exists)->
        return done(err) if err
        return done(null) if not exists
        done({msg: "gitlab仓库已存在，请填写其他名称"})
    )
  )

  #创建git项目
  queue.push((done)->
    gitlab.projects().post(
      name: gitlab_name
      visibility_level: 20
      description: ""
    ).then((project)->
      done null, project.id, project.ssh_url_to_repo
    ).catch((e)->
      done(msg:"git仓库创建失败")
    )
  )

  #设置hooks
  queue.push((git_id, git_url, done)->
    gitlab.projects(git_id).hooks().post(_config.gitlab.hooks)
      .then(->
        done(null, git_id, git_url)
      )
      .catch((err)->
        done({msg: "gits设置hooks失败, 请检查是否具有该仓库权限！", err: err})
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
