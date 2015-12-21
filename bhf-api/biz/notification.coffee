###
  处理通知相关的，如落地的消息，用户的数据流
###
_util = require 'util'
_common = require '../common'
_entity = require '../entity'
_async = require 'async'
_http = require('bijou').http
_stream = require('../redis/stream')
_moment = require 'moment'

_streamEvt  = _common.enumerate.streamEventName


dateAgo = (date)->
  dt = new Date(date)
  return '今天' if new Date().toDateString() is dt.toDateString()
  return '昨天' if new Date().toDateString() is new Date(date + 24 * 3600 * 1000).toDateString()
  return _moment(date).format('YYYY-MM-DD')

#获取Stream的标题
getStreamSubject = (stream, member_id)->
  subject = "未知事件"
  switch stream.eventName
    when _streamEvt.mention then subject = "#{stream.sender}提到了您"
    when _streamEvt.statusChange then subject = "#{stream.sender}改变了任务状态"
    when _streamEvt.assetPost then subject = "#{stream.sender}上传了文件";
    when _streamEvt.issueAssigned
      owner = if stream.owner is member_id then "您" else stream.owner_name
      subject = "#{stream.sender}给#{owner}指定了任务"
      subject += "，【#{_moment(stream.data.plan_finish_time).format('YYYY-MM-DD')}】" if stream.data.plan_finish_time
    when _streamEvt.commentPost then subject = "#{stream.sender}添加了评论"
    when _streamEvt.invitation then subject = "#{stream.sender}邀请您加入#{stream.data.teamName}"

  subject

#获取用户自己的所有消息
exports.getMessage = (client, cb)->
  cond =
    receiver_id: client.member.member_id
    status: client.query.status

  options =
    orderBy:  id: 'desc'
    pagination: _entity.message.pagination client.query.pageIndex, client.query.pageSize

  _entity.message.find cond, options, cb

#设置消息为只读，可以只读某一条消息，或者某个时间之前的消息
exports.readMessage = (client, cb)->
  id = client.params.id
  timestamp = parseInt client.query.timestamp
  data = status: 'read'
  cond = receiver_id: client.member.member_id

  options =
    beforeQuery: (query)->
      if id
        query.where id: id
      else
        timestamp = new Date().valueOf() if isNaN(timestamp)
        query.where 'timestamp', '<', timestamp

  _entity.message.update cond, data, options, cb

#读取当前用户的数据流
exports.readStream = (client, cb)->
  member_id = client.member.member_id
  _stream.getStream member_id, cb

#读取当前用户的数据流
exports.readDailyStream = (client, cb)->
  member_id = client.member.member_id
  _stream.getStream member_id, (err, items)->
    days = []
    day = {
      title: '',
      timestamp: 0,
      items: []
    }
    for item, index in items
      item.timeAgo = _moment(item.timestamp).fromNow()
      item.subject = getStreamSubject item

      if (index > 0 and new Date(item.timestamp).toDateString() is new Date(items[index - 1].timestamp).toDateString()) or index is 0
        day.items.push item
      else
        days.push {
          title: day.title
          timestamp: day.timestamp,
          items: day.items
        }
        day.items = [item]
      day.timestamp = item.timestamp
      day.title = dateAgo item.timestamp

      days.push day if index + 1 is items.length

    cb err, days
