assert = require 'assert'
#c3c38fb0-0e89-11e5-a67e-470a21a93a14
_async = require 'async'
request = require 'request'

describe("测试 权限请求", ->

  it("免权限接口 /api/user, post, 通过", (done)->
    request.post("http://localhost:3000/api/user", {form: {
      username: "test2"
      password: "123456"
      password_repeat: "123456"
    }}, (error, resp, body)->
      console.log body
      resp.statusCode.should.eql(200)
      done(error)
    )
  )

  it("免权限接口 /api/user, get, 不能通过", (done)->
    request("http://localhost:3000/api/user", (error, resp, body)->
      resp.statusCode.should.eql(403)
      done()
    )
  )

  it("免权限接口 /api/token, post, 通过", (done)->
    request.post("http://localhost:3000/api/token", {form: {
        username: "test2"
        password: "123456"
      }}, (error, resp, body)->
      resp.statusCode.should.eql(200)
      done(error)
    )
  )

  it("免权限接口 /api/token, get, 不能通过", (done)->
    request("http://localhost:3000/api/token", (error, resp, body)->
      resp.statusCode.should.eql(403)
      done()
    )
  )

  it("免权限接口 /api/message/weixin, get, 不能通过", (done)->
    request("http://localhost:3000/api/message", (error, resp, body)->
      resp.statusCode.should.eql(403)
      done()
    )
  )

  it("免权限接口 /api/message/weixin, get, 能通过", (done)->

    queue = []

    queue.push((callback)->
      request.post("http://localhost:3000/api/token", {form: {
          username: "test2"
          password: "123456"
        }, json: true},
        (error, resp, body)->
          callback(error, body.private_token)
      )
    )

    queue.push((token, callback)->
      request(
        {
          url: "http://localhost:3000/api/message/weixin",
          headers: {private_token: token}
        },
        (error, resp, body)->
          callback(error, resp.statusCode)
      )
    )

    _async.waterfall(queue, (error, statusCode)->
      statusCode .should.eql(200)
      done()
    )

  )
)