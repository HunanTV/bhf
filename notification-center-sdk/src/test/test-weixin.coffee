weixin = require('../index').weixin

describe("消息通知", ()->

  it("发微信", (done)->
    weixin("huyinghuan", "Message SDK test", (error, statuscode)->
      console.log error, statuscode
      done()
    )
  )
)