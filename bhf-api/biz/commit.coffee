###
  git commit相关
###

_async = require 'async'
_ = require 'lodash'
_path = require 'path'
_http = require('bijou').http
_GitLabInterface = require('gitlab-few')

_common = require '../common'
_entity = require '../entity'
_issueBiz = require './issue'
_mailer = require '../notification/mailer'
_entityMember = require '../entity/member'
_config = require('../common').config
_cache = require '../cache'
_gitlab = require './gitlab'
commits = []
commits_temp = []

#过滤掉message中包含的指令及头尾的空格
commitMessageFilter = (message)->
  message = message.replace(/#([\w\d_]+)\s/ig, '')
    .replace(/#(\d+)[-](\d+)[\s$]/ig, '')
    .replace(/@([\w\d_]+)\s/, '')
    .replace(/!([\w\d_]+)\s/, '')
    #过滤掉#p-108这类指令
    .replace(/#p\-\d+\s/i, '')

  message = _common.trim message
  message


#转换commit到issue
commitMessageToIssue = (project_id, message, member_id, timestamp, cb)->
  #提取issue_id
  issue_id = null 
  issue_split_id = null
  if /#(\d+)[\s$]/i.test message
    issue_id = RegExp.$1 
  else if /#(\d+)[-](\d+)[\s$]/i.test message 
  #如果存在子issue则提取issue_id和子issue_id
    issue_id = RegExp.$1 
    issue_split_id = RegExp.$2 
  else 
    return cb null
  #提取版本
  version = if /!([\w\d_]+)[\s$]/i.test message then RegExp.$1 else null
  #提取分类
  category = if /@([\w\d_]+)[\s$]/i.test message then RegExp.$1 else null
  #提取状态
  status = if /#(doing|pause|done)[\s$]/i.test message then RegExp.$1 else null
  #是否需要创建issue
  isCreate = (parseInt(issue_id) <= 0 or /#(create|new)/i.test(message)) and project_id and member_id
  #是否需要创建子issue
  isCreateSplit = (parseInt(issue_split_id) <= 0) and issue_id and member_id
  console.log isCreateSplit
  queue = []
  version_id = null
  category_id = null
  #获取活动的分类
  queue.push(
    (done)->
      return done null if not isCreate or not category

      cond = project_id: project_id, short_title: category
      _entity.issue_category.findOne cond, (err, result)->
        category_id = result?.id
        done null
  )

  #找到版本的id
  queue.push(
    (done)->
      return done null if not isCreate or not version

      cond = project_id: project_id, short_title: version
      _entity.version.findOne cond, (err, result)->
        version_id = result?.id
        done null
  )

  #如果没有指定版本id，则查找活动的版本id
  queue.push(
    (done)->
      return done null if not isCreate or version_id

      cond = project_id: project_id, status: 'active'
      _entity.version.findOne cond, (err, result)->
        version_id = result?.id
        done null
  )

  #保存issue
  queue.push(
    (done)->
      return done null if not isCreate

      #替换掉message中的标签
      data =
        title: commitMessageFilter message
        status: status || 'doing'
        tag: 'issue'
        creator: member_id
        owner: member_id
        timestamp: timestamp || Number(new Date())
        project_id: project_id
        version_id: version_id
        category_id: category_id

      _entity.issue.save data, (err, id)->
        issue_id = id
        done err

        _issueBiz.writeLog member_id, id, '创建'
  )


  queue.push(
    (done)->
      return done null if not isCreateSplit
      data =
        id: issue_id
        splited: 1
      _entity.issue.save data, (err, id)->
        done err

  )

  queue.push(
    (done)->
      return done null if not isCreateSplit
      data =
        title: commitMessageFilter message
        status: status || 'doing'
        creator: member_id
        owner: member_id
        timestamp: timestamp || Number(new Date())
        issue_id:issue_id
      _entity.issue_split.save data, (err, id)->
        done err

  )


  #处理状态
  queue.push(
    (done)->
      return done null if not (issue_id and !issue_split_id and  status is 'done' and member_id)
      #console.log 'done', issue_id
      #如果有done标签，则完成这个issue
      _entity.issue.finishedIssue issue_id, member_id, (err, result)->
        done err

      _issueBiz.writeLog member_id, issue_id, "更改状态->#{status}"
  )

  #处理状态
  queue.push(
    (done)->
      return done null if not (issue_id and issue_split_id and  status is 'done' and member_id)
      #console.log 'done', issue_id
      #如果有done标签，则完成这个issue
      _entity.issue_split.finishedIssue issue_split_id, member_id, done

      _issueBiz.writeLog member_id, issue_id, "更改子任务#{issue_split_id}状态->#{status}"
  )

  _async.waterfall queue, (err)-> cb err, issue_id

#转成标准comit格式
commitConverter = (commit)->
  standard = {}
  standard.project_id = commit.project_id
  standard.email = commit.email or commit.author.email
  standard.message = commit.message
  standard.timestamp = commit.timestamp
  standard.sha = commit.sha or commit.id
  standard.url = commit.url
  standard

#暂存多个commit
tempCommits = (project_id, commitlist, cb)->
  index = 0
  _async.whilst(
    (-> index < commitlist?.length)
    ((done)->
      commit = commitlist[index++]
      cond = sha: (commit.id or commit.sha)
      _entity.commit.exists cond, (err, exists)->
        return done null if exists

        commit.project_id = project_id
        data = commitConverter commit
        tempCommit data, 'temp', done
    )
    cb
  )

#保存多个commit
saveCommits = (cb)->
  index = 0
  commits = commits.concat commits_temp
  commits_temp = []
  _async.whilst(
    (-> index < commits?.length)
    ((done)->
      commit = commits[index++]
      _entity.commit.save commit, (err)-> done err
    )
    cb
  )

#保存commit
tempCommit = exports.saveCommit = (commit, type, cb)->
  cb = type if typeof type is 'function'
  queue = []
  data =
    project_id: commit.project_id
    message: commitMessageFilter commit.message
    sha: commit.sha
    email: commit.email
    url: commit.url
    timestamp: new Date(commit.timestamp).valueOf()
    # timestamp: new Date(parseInt(commit.timestamp)).valueOf()


  isGroup = /#group/i.test(commit.message)
  issue_id = if /#(\d+)[\s$]/i.test commit.message then RegExp.$1 else null

  #根据commit.author.email查找对应的用户
  queue.push(
    (done)-> _entity.git_map.findMemberId commit.email, (err, member_id)->
      return done err if err
      data.creator = member_id
      done null
  )

  #分析issue中的issue_id等特殊标签
  queue.push(
    (done)->
      #分析message中的信息，例如关于到issue，或者完成某个issue等
      commitMessageToIssue commit.project_id, commit.message, data.creator, data.timestamp, (err, issue_id)->
        return done null if err
        data.issue_id = issue_id
        done err
  )
  if type and type is 'temp'
    #暂存commit
    queue.push(
      (done)-> 
        commits_temp.push data
        return done null if !isGroup && !issue_id
        commit.issue_id = data.issue_id for commit in commits_temp when !commit.issue_id if isGroup
        commits = commits.concat commits_temp
        commits_temp = []
        done null
    )
  else
    #保存commit
    queue.push(
      (done)-> _entity.commit.save data, (err)-> done err
    )
  #如果没有找到对应的project_id与creator，向原用户发送邮件
  queue.push(
    (done)->
      return done null #暂时不发邮件

      return done null if data.project_id and data.creator

      subject = "您的项目git地址关联有误"
      content = "您的项目没有关联Git，请检查。"
      #TODO !!! 这里需要去除网站信息
      content += "<a href='http://bhf.hunantv.com/wiki/17/issue/2993' target='_blank'>如何关联GitLab与BHF？</a>"

      _mailer.addTask data.email, subject, content
      done null
  )

  _async.waterfall queue, cb



###
  #处理git commit
###
exports.postCommit = (client, cb)->
  data = client.body
  # data.repository = JSON.parse data.repository
  # data.commits = JSON.parse data.commits
  #数据格式不正确
  return cb _http.notAcceptableError('数据格式有误') if not data?.repository

  queue = []
  #取得projectid
  queue.push(
    (done)->
      #如果在url中指定了project_id，则不用再去查找
      project_id = client.params.project_id
      return done null, project_id if project_id
      _entity.git_map.findProjectId data.repository.url, done
  )

  #暂存每一个commit
  queue.push(
    (project_id, done)->
      tempCommits project_id, data.commits, done
  )

  #保存每一个commit
  queue.push(
    (done)->
      saveCommits done
  )

  #queue.push
  _async.waterfall queue, (err)->
    commits = []
    return cb err if err
    #bho需要返回success: true
    cb err, success: true

#查找commit
exports.get = (client, cb)->
  cond =
    project_id: client.params.project_id
    issue_id:  client.params.issue_id

  pagination = _entity.commit.pagination client.query.pageIndex, client.query.pageSize
  _entity.commit.fetch cond, pagination, cb

#导入commits

exports.import = (client, cb)->
  member_id =  client.member.member_id
  project_id = client.query.project_id
  #git项目id
  git_project_id = client.query.git_project_id
  #git项目分支名
  git_project_branch = client.query.git_project_branch
  #导入commits的数量
  limit = parseInt(client.query.limit) or 50
  #另外还需 用户 token, git 项目相关信息
  queue = []
  token = _cache.member.get(member_id).gitlab_token

  gitlab = new _GitLabInterface(token, _config.gitlab.api)

  #获取项目相关信息（web地址）
  queue.push(
    (done)->
      gitlab.projects(git_project_id)
        .get().then((data)->
          done null, data.web_url
        )
        .catch((err)->done err)
  )

  #获取并处理相关commits
  queue.push(
    (web_url, done)->
      gitlab.projects(git_project_id)
        .commits().get(git_project_branch, {limit: limit})
        .then((result)->
          commits = []
          for item in result
            commits.push({
              message: item.message
              sha: item.id
              email: item.author_email
              url: "#{web_url}/commit/#{item.id}"
              timestamp: item.created_at
            })
          done null, commits
        )
        .catch((err)->done err)
  )

  #暂存commits
  queue.push(
    (commits, done)->
      tempCommits project_id, commits, done
  )

  #保存commits
  queue.push((done)-> saveCommits done)

  _async.waterfall(queue, (err, result)->
    commits = []
    cb err
  )

exports.toString = -> _path.basename __filename