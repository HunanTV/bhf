email = require('../index').email

describe("消息通知", ()->

  it("发邮件", (done)->
    email("test message SDK", "646344359@qq.com", "hello world", (error, statuscode)->
      console.log error, statuscode
      done()
    )
  )
)