assert = require 'assert'
_smtp = require('../config').mail
_nodemailer = require 'nodemailer'
_smtpTransport = require 'nodemailer-smtp-transport'

transport = _nodemailer.createTransport(_smtpTransport(_smtp))
request = require 'request'

token = "9cb312d0-14d1-11e5-b79b-bfa179cfc352"

describe("邮件测试", ->

  it("基本发送测试", (done)->
    transport.sendMail({
      from: _smtp.auth.user,
      to: '646344359@qq.com',
      subject: 'hello',
      text: 'hello world!'
    }, (error, info)->
      console.log error, info
      done(error)
    )
  )

  it("HTTP接口成功测试", (done)->
    request.post(
      {
        url: "http://localhost:3000/api/message/email",
        headers: {private_token: token}
        formData: {
          to: "xiacijian@163.com",
          subject: "no title"
          text: "hello This is macha test message a"
        }
      },
      (error, resp, body)->
        console.log error
        console.log resp.statusCode
        console.log body
        done()
    )
  )

  it("HTTP接口失败测试", ()->
    request.post(
      {
        url: "http://localhost:3000/api/message/email",
        headers: {private_token: token}
        formData: {
          to2d: "646344359@qq.com",
          subject: "no title"
          text: "hello This is macha test message"
        }
      },
      (error, resp, body)->
       # callback(error, resp.statusCode)
        console.log error
        console.log resp.statusCode
        console.log body
    )
  )

)