_mailer = require './mailer'
_entity = require '../entity'
_common = require '../common'
_realtime = require './realtime'
_async = require 'async'
_moment = require 'moment'
_cache = require '../cache'
_ = require 'lodash'
#_message = require './message'
_pusher = require './pusher'
_stream = require '../redis/stream'
_wechat = require './wechat'

_streamEvt  = _common.enumerate.streamEventName

#提到某个项目的所有成员
mentionAllMemberOfProject = (sender_id, issue, comment)->
  #房间消息发送
  mentionViaRealtime sender_id, issue.project_id, issue, comment, 'project'
  #获取所有的成员
  members = _cache.getAllMemberOfProject issue.project_id
  #向项目中的所有成员发邮件
  for member_id in members
    mentionViaMail sender_id, member_id, issue, comment

#提到所有成员
mentionAllMember = (sender_id, issue, comment)->
  mentionViaRealtime sender_id, null, issue, comment, 'all'
  #获取全部成员，并向他们发送邮件
  members = _cache.getAllMember()
  for key, member of members
    mentionViaMail sender_id, member.id, issue, comment

#提到某个人，或者某个群体
mentionObject = (sender_id, keyword, issue, comment)->
  switch keyword
    #提到当前项目
    when 'project' then mentionAllMemberOfProject sender_id, issue, comment
    #提到所有人
    when 'all' then mentionAllMember sender_id, issue, comment
    #提到具体的人
    else mentionSomeone sender_id, keyword, issue, comment

#提到某个人，已经明确接收者
mentionViaMail = (sender_id, receiver_id, issue, comment)->
  console.log "发邮件 -> #{receiver_id}"
  receiver = _cache.member.get receiver_id
  sender = _cache.member.get sender_id

  #构造邮件信息
  content = comment?.content || issue.content
  subject = "#{sender.realname}提到了你->#{issue.title}"
  body = "主题: #{issue.title}<br /><br />"
  body += "内容： #{content}<br />" if content
  body += _common.issueLink issue.project_id, issue.id

  #添加到邮件
  _mailer.addTask receiver.email, subject, body
  link = _common.issueLink issue.project_id, issue.id, true
#  _message.post sender_id, receiver_id, subject, link

#通过推送发送给某人
mentionViaPusher = (sender_id, receiver_id, issue, comment)->
  sender = _cache.member.get sender_id
  message = "#{sender.realname}提到了你->#{issue.title}"
  _pusher.postToMember receiver_id, message

#通过实时通知提到某人
mentionViaRealtime = (sender_id, receiver_id, issue, comment, target)->
  #实时通知
  data =
    issue: issue
    comment: comment
    link: _common.issueLink issue.project_id, issue.id, true

  event = 'mention'
  switch target
    when 'project' then _realtime.postToProject sender_id, receiver_id, event, data
    when 'all' then _realtime.broadcast sender_id, event, data
    else _realtime.postToMember sender_id, receiver_id, event, data

#提到某个人，未明确接收者
mentionSomeone = (sender_id, keyword, issue, comment)->
  options =
    beforeQuery: (query)->
      query.where ->
        this.where 'username', '=', keyword
        this.orWhere 'realname', '=', keyword

  _entity.member.findOne {}, options, (err, member)->
    #没有找到提到的人或者错误
    return if err or not member
    mentionViaMail sender_id, member.id, issue, comment
    mentionViaRealtime sender_id, member.id, issue, comment, 'member'
    mentionViaPusher sender_id, member.id, issue, comment

    #推送微信消息
    sender = _cache.member.get sender_id
    receive = _cache.member.get member.id
    message = "#{sender.realname}提到了您->#{issue.title}"
    _wechat.addTask sender, receive, message

    #推入到stream
    streamData =
      issue_id: issue.id
      title: issue.title
      content: comment?.content || issue.content
      project_id: issue.project_id

    _stream.append sender, receive, _streamEvt.mention, streamData


#检测在标题或者内容中是否提到了某人
exports.addTask = (names, issue_id, comment_id)->
  return if not (names and names.length > 0)

  tasks = {
    issue: (done)-> _entity.issue.findById issue_id, done
    comment: (done)->
      return done null if not comment_id
      _entity.comment.findById comment_id, done
  }

  _async.series tasks, (err, result)->
    return if err

    sender_id = result.comment?.creator || result.issue.creator
    for name in names
      mentionObject sender_id, name, result.issue, result.comment