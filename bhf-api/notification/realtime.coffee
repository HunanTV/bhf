_common = require '../common'
_cache = require '../cache'
_entity = require '../entity'

#用户的房间
_rooms = project: {}, all: {}
#在线用户
_online = {}
_io = null
#用户在线的房间
ONLINE = 'online'

#获取项目房间的名称
getProjectRoomName = (project_id)-> "project_#{project_id}"

#将一个用户加入自己的项目的房间
joinToMyProject = (member_id)->
  socket = _online[member_id]
  projects = _cache.projectMember.getProjects member_id
  #加入用户到不同的项目房间
  socket.join getProjectRoomName(project_id) for project_id in projects

#用户离开自己的所有房间（用户disconnect会自动退出room，暂不需要考虑）
leaveMyProject = (member_id)->
  socket = _online[member_id]
  _entity.project_member.findMyProject member_id, (err, projects)->
    #加入用户到不 同的项目房间
    socket.leave getProjectRoomName(item.project_id) for item in projects

#上线通知
onlineNotifiy = (member_id)->

#获取所有在线的用户
getOnlineMember = ()->
  _cache.member.get key for key in _online

#向指定用户发送消息
postToMember = exports.postToMember = (sender_id, receiver_id, event, data)->
  socket = _online[receiver_id]
  
  return false if not socket
#    console.log _cache.member.get(receiver_id).realname, '用户不在线'

  sender = _cache.member.get sender_id if sender_id
  receiver = _cache.member.get receiver_id
  message =
    data: data
    sender: sender
    event: event
    receiver: receiver

#  console.log message
#  console.log 'To', receiver.realname
  socket.emit 'message',  message

#发消息给指定的房间
postToRoom = (room_id, message)->
  if socket = _io.room room_id
    socket.broadcast 'message', message

#向某个项目发送所有消息
postToProject = exports.postToProject = (sender_id, project_id, event, data)->
  message =
    data: data
    sender: _cache.member.get(sender_id) if sender_id
    event: event
    project: _cache.project.get(project_id)

  postToRoom getProjectRoomName(project_id), message

#向所有用户发送消息
broadcast = exports.broadcast = (sender_id, event, data)->
  message =
    data: data
    sender: _cache.member.get(sender_id) if sender_id
    event: event

  postToRoom ONLINE, message

#某个用户加入了，将用户加到不同项目的房间
exports.online = (member_id, socket)->
#  console.log _cache.member.get(member_id).realname, "加入进来了"
  #将在线用户加入到一个在线的房间
  socket.join ONLINE

  if _online[member_id]
    #socket已经存在，替换新的
    _online[member_id] =  socket
    #将当前用户加入到room
    joinToMyProject member_id
    return;

  #加进online的列表
  _online[member_id] = socket
  #广播通知用户在线
  #broadcast member_id, 'online', null
  #将用户加到项目房间
  joinToMyProject member_id

#用户离线了
exports.offline = (member_id)->
  delete _online[member_id] if _online[member_id]

#将在线的用户加入到某个项目
exports.joinProject = (project_id, member_id)->
  if socket = _online[member_id]
    socket.join getProjectRoomName(project_id)

#用户离开某个项目
exports.leaveProject = (project_id, member_id)->
  if socket = _online[member_id]
    #退出某个房间
    socket.leave getProjectRoomName(project_id)

#收到消息后再处理
exports.receiveMessage = (member_id, message)->
  switch message.event
    #向所有人广播
    when 'talk:all' then broadcast member_id, message.event, message.data
    #向指定项目广播
    when 'talk:project' then postToProject member_id, message.data.project_id, message.event, message.data
    #向指定用户广播
    when 'talk:member' then postToMember member_id, message.data.member_id, message.event, message.data
    #获取所有在线用户
    when 'online:all' then postToMember null, message.event, getOnlineMember()

#检测用户是否在线
exports.isOnline = (member_id)-> !!_online[member_id]

exports.init = (app)->
  _io = app.io