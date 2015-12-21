bodyParser = require 'body-parser'
multer = require 'multer'

app = require('express')()
server = require('http').createServer(app)
io = require('socket.io')(server)

config = require './config'
_Router = require('./router')(io)
messageStack = require './message-stack'
_global = require './global'

server.listen(config.port)

app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: true }))
app.use(multer())

app.use(_Router.get())

io.on('connection', (socket)->
  if socket.handshake.query.token isnt config.token
    return socket.disconnect()

  _global.client_count = _global.client_count + 1

  socket.on('disconnect', ()->
    client_count = _global.client_count
    _global.client_count = if client_count > 1 then client_count - 1 else 0
  )

  socket.on('api:response', (mid, statusCode, headers, data)->
    cb = messageStack.pop(mid)
    cb(statusCode, headers, data) if cb
    ###
      应该增加相关记录，及时反馈 处理完成却没有响应到数据
    ###
  )
)
