assert = require 'assert'

WeiXinDispacther = require '../dispatcher/weixin'

async = require 'async'

test = ->
  queue = []
  for i in [0..15]
    queue.push((cb)->
      WeiXinDispacther.push({a: new Date().getTime()}, (statusCode)->
        cb()
      )
    )
  async.whilst(->
    queue.length
  ,(cb)->
    work = queue.pop()
    work(cb)
  , ->
  )

  setTimeout(()->
    WeiXinDispacther.push({a: new Date().getTime()}, (statusCode)->)
  , 1000)

#test()