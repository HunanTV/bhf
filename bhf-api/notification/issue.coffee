#    Author: 易晓峰
#    E-mail: wvv8oo@gmail.com
#    Date: 6/30/15 4:25 PM
#    Description: 与issue相关的通知

_async = require 'async'
_ = require 'lodash'
_moment = require 'moment'

_entity = require '../entity'
_cache = require '../cache'
_common = require '../common'
_mailer = require './mailer'
_realtime = require './realtime'
_stream = require '../redis/stream'
_pusher = require './pusher'
_wechat = require './wechat'

_streamEvt  = _common.enumerate.streamEventName

#获取任务，子任务（如果有），任务的followers
exports.getIssueAndFollowers = getIssueAndFollowers = (sender, issue_id, issue_split_id, cb)->
  if _.isFunction issue_split_id
    cb = issue_split_id
    issue_split_id = null

  queue = []
  result = {}

  #读取拆分的任务数据，如果有的话
  queue.push(
    (done)->
      return done null if not issue_split_id
      _entity.issue_split.findById issue_split_id, (err, issue_split)->
        result.issue_split = issue_split
        done err
  )

  #获取issue
  queue.push(
    (done)->
      _entity.issue.findById issue_id, (err, issue)->
        result.issue = issue
        return done err if err or not issue
        done err
  )

  #获取关注者
  queue.push(
    (done)->
      cond = issue_id: issue_id
      _entity.issue_follow.find cond, (err, people)->
        return done err if err

        followers = []
        data = result.issue_split || result.issue
        followers.push data?.creator
        followers.push data?.owner

        _.map people, (current)-> followers.push current.member_id
        followers = _.uniq followers

        #去掉当前用户
        _.remove followers, (current)-> current is sender.id
        result.followers = followers
        done err
  )

  _async.waterfall queue, (err)->
    return cb err if err or not result.issue

    result.stream = getStreamData result.issue, result.issue_split
    result.realtime =
        issue: result.issue
        issue_split: result.issue_split
        link: _common.issueLink(result.issue.project_id, result.issue.id, true)
    cb err, result

#获取流的数据
getStreamData = (issue, issue_split)->
  #添加到活动中
  data = issue_split || issue

  result =
    owner_id: data.owner
    owner_name: _cache.member.get(data.owner)?.realname
    plan_finish_time: data.plan_finish_time
    status: data.status
    title: data.title

  result.is_split = Boolean(issue_split)
  result.project_id = issue.project_id
  result.issue_id = issue.id
  if issue_split
    result.issue_title = issue.title
    result.issue_split_title = issue_split.title
    result.title = "#{issue.title}->#{issue_split.title}"
  result

#通知任务的所有者
sendToOwner = (sender, receiver, isChangeExpire, title, plan_finish_time, link)->
#指定了过期时间，则在标题中添加什么时候到期
  if isChangeExpire
    expire = _moment(plan_finish_time).format('YYYY-MM-DD')
    subject = "#{sender.realname}设定了任务将于#{expire}到期：#{title}"
  else
    subject = "#{sender.realname}给您指定了任务：#{title}"

  body = title
  body += "，将于#{expire}到期" if expire

  body += "</br>#{link}"

  #发送邮件通知
  _mailer.addTask receiver.email, subject, body
  #给owner推送微信
  _wechat.addTask sender, receiver, subject
  #给owner推送iOS消息
  _pusher.postToMember receiver.id, subject

# 分配任务触
exports.takeTask = (sender_id, issue_id, isChangeExpire, issue_split_id)->
  eventName = _streamEvt.issueAssigned
  sender = _cache.member.get sender_id

  getIssueAndFollowers sender, issue_id, issue_split_id, (err, result)->
    return if err or not result.issue

    link = _common.issueLink(result.issue.project_id, result.issue.id)
    owner = _cache.member.get(result.issue_split?.owner or result.issue.owner)

    #不是自己指定自己的情况下，才向owner通知
    if sender_id isnt owner?.id
      sendToOwner sender, owner, isChangeExpire, result.stream.title, result.stream.plan_finish_time, link

    #通知每一个人，关注的人，只会收到stream
    _.map result.followers, (follower)->
      receiver = _cache.member.get follower
      #如没有找到接收者，不处理
      return if not receiver

      #实时通知
      #_realtime.postToMember sender_id, receiver.id, eventName, result.realtime
      #消息记录
      _stream.append sender, receiver, eventName, result.stream

#更改任务或者子任务的状态
exports.changeStatus = (sender_id, issue_id, issue_split_id)->
  sender = _cache.member.get sender_id
  eventName = _streamEvt.statusChange

  #获取任务和所有的关注者
  getIssueAndFollowers sender, issue_id, issue_split_id, (err, result)->
    return if err or not result.issue

    if result.issue.status is 'done'
      subject = "#{sender?.realname}完成了任务：#{result.stream.title}"
    else
      subject = "#{sender?.realname}更改了状态【#{result.stream.status}】：#{result.stream.title}"

    body = _common.issueLink(result.issue.project_id, result.issue.id)

    #通知每一个用户
    _.map result.followers, (follower)->
      receiver = _cache.member.get follower
      return if not receiver

      #更改任务状态是比较重要的活动，需要向所有人发送邮件，推送，实时消息，stream
      _mailer.addTask receiver.email, subject, body if receiver.email
      #通知相当人等
      _pusher.postToMember receiver.id, subject
      #实时消息
      _realtime.postToMember sender_id, receiver.id, eventName, result.realtime
      #写入stream
      _stream.append sender, receiver, eventName, result.stream