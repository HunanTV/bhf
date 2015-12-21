mobilPusher = require('../index').mobilPusher

describe("消息通知", ()->

  it("手机推送", (done)->
    mobilPusher("061e3470869", "ios", "hello world", {a: 1}, (error, statuscode)->
      console.log error, statuscode
      done()
    )
  )
)