#消息队列
stack = {}

timerStack = {}


_timeout = require('./config').timeout

class Message
  constructor: ->

  push: (mid, cb)->
    stack[mid] = cb
    timer = setTimeout(->
      if stack.hasOwnProperty(mid)
        delete stack[mid]
        cb(502, {}, "")

      #删除存储的定时器
      delete timerStack[mid] if timerStack.hasOwnProperty(mid)

    , _timeout)

    #保存好定时器
    timerStack[mid] = timer

  pop: (mid)->
    cb = stack[mid]
    delete stack[mid] if stack.hasOwnProperty(mid)
    #清除定时器
    clearTimeout(timerStack[mid]) if timerStack[mid]
    delete timerStack[mid] if timerStack.hasOwnProperty(mid)
    cb

module.exports = new Message()