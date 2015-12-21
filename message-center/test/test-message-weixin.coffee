assert = require 'assert'
async = require 'async'
request = require 'request'
token = "9cb312d0-14d1-11e5-b79b-bfa179cfc352"

describe("发送消息到微信", ->

  it("发送", (done)->
    request.post(
      {
        url: "http://localhost:3000/api/message/weixin",
        headers: {private_token: token}
        formData: {touser: "huyinghuan", content: "hello This is macha test message"}
      },
      (error, resp, body)->
        done()
    )
  )

)