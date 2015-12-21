#负责将邮件扔到队列，并通知用户
_common = require '../common'
_async = require 'async'
_cache = require '../cache'
_nc = require('notification-center-sdk')

_fifo = []

#发送邮件
sendmail = exports.sendmail = (mailto, subject, body, cb)->
  if not _common.config.notification.email
    console.log "发邮件功能被禁止"
    return cb? null

  #没有合法的邮件地址
  return if not mailto
  console.log "mailTo: #{mailto} -> #{new Date()}"
  _nc.email(subject, mailto, body, (error, statuscode)->
    console.log("发送邮件失败") if error or statuscode isnt 200
    cb?(null)
  )

#执行任务
execute = ()->
  _async.whilst(
    -> _fifo.length > 0
    (done)->
      item = _fifo.shift()
      console.log "发邮件[fifo] -> #{item.mailto}"
      sendmail item.mailto, item.subject, item.body, done
    -> #邮件任务发送完成
  )

#TODO 这里要加入用户的ID，某些用户设置不接收邮件，可以在此阻止
#提交邮件任务
addTask = exports.addTask = (mailto, subject, body)->
  console.log "新邮件任务 -> #{mailto}"
  _fifo.push mailto: mailto, subject: subject, body: body
  execute()

#发邮件给所有人
exports.mailToAll = (sender_id, subject, body)->
  sender = _cache.member.get(sender_id)
  body += '============================================================<br />'
  body += "本邮件由【#{sender.realname}】通过BHF发送"

  #获取所有用户
  for key, member of _cache.getAllMember()
    #跳过自己和没有地址的
    continue if member.id is sender_id or not member.email
    addTask member.email, subject, body

#发送加入团队的邀请函
exports.joinTeamInvitation = (sender_id, receiver_id, teamName)->
  sender = _cache.member.get sender_id
  receiver = _cache.member.get receiver_id
  return if not(sender and receiver)

  subject = "【#{sender.realname}】邀请您加入【#{teamName}】"
  body = "【#{sender.realname}】邀请您加入他在BHF的团队【#{teamName}】，请登录BHF查看。<br />
                  #{_common.inviteLink(false)}"
  addTask receiver.email, subject, body
