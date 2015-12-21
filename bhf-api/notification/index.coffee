_async = require 'async'
_moment = require 'moment'
_ = require 'lodash'

_mailer = require './mailer'
_entity = require '../entity'
_common = require '../common'
_realtime = require './realtime'
_cache = require '../cache'
_mention = require './mention'
_pusher = require './pusher'
_stream = require '../redis/stream'
_wechat = require './wechat'
_issue = require './issue'
_streamEvt  = _common.enumerate.streamEventName

#提取某人
exports.mention = (names, issue_id, comment_id)->
  _mention.addTask names, issue_id, comment_id

#欢迎用户
exports.welcome = (mailto, realname)->
  subject = "欢迎加入BHF"
  body = "hi, #{realname}，你的帐号已经创建，建议修改密码。<br />
          访问地址：#{_common.config.host}"
  _mailer.addTask mailto, subject, body

#通知用户已经
exports.joinProject = (project_id, receive_id, sender_id)->
  receiver = _cache.member.get receive_id
  sender = _cache.member.get sender_id
  #如果用户没有邮箱，又不在线，则不处理
  return if not (receiver?.email or _realtime.isOnline receive_id)

  _entity.project.findById project_id, (err, project)->
    return if err or not project

    #邮件
    subject = "欢迎加入#{project.title}"
    body = "你被#{sender?.realname}加入到#{project.title}"
    _mailer.addTask receiver?.email, subject, body

    #实时通知
    data = project: project
    _realtime.postToMember sender_id, receive_id, 'project:join', data

#用户添加了评论，需要提醒关注的人，任务的所有者，创建任务的人
exports.addComment = (sender_id, issue_id, content)->
  eventName = _streamEvt.commentPost
  sender = _cache.member.get sender_id

  _issue.getIssueAndFollowers sender, issue_id, (err, result)->
    return if err or not result
    result.stream.comment = content #交给客户端去处理html与超长的问题
    
    _.map result.followers, (follower)->
      receiver = _cache.member.get follower
      _stream.append sender, receiver, eventName, result.stream

#添加素材
exports.addAsset = (data)->
  #没有指定issue_id的素材
  return if not data.issue_id
  eventName = _streamEvt.assetPost
  sender = _cache.member.get data.creator

  _issue.getIssueAndFollowers sender, data.issue_id, (err, result)->
    _.extend result.stream, {
      original_name: data.original_name
      file_size: data.file_size
      file_type: data.file_type
      file_name: data.file_name
      asset_id: data.id
      url: _common.assetUrl data.project_id, data.file_name  
    }

    _.map result.followers, (follower)->
      receiver = _cache.member.get follower
      _stream.append sender, receiver, eventName, result.stream

#加入团队的邀请
exports.joinTeamInvitation = (sender_id, receiver_id, teamName)->
  eventName = _streamEvt.invitation
  sender = _cache.member.get sender_id
  receiver = _cache.member.get receiver_id
  message = "#{sender.realname}邀请您加入到#{teamName}，请登录BHF接受或者拒绝"

  _mailer.joinTeamInvitation sender_id, receiver_id, teamName

  #加入stream
  streamData = teamName: teamName
  _stream.append sender, receiver, eventName, streamData

  #微信
  _wechat.addTask sender, receiver, message
  #移动设备推送
  _pusher.postToMember receiver.id, message
  #实时消息
  _realtime.postToMember sender_id, receiver_id, eventName, streamData