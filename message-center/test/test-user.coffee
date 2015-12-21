assert = require 'assert'
config = require './config'
_ = require 'lodash'

describe("Database", ()->
  user = require '../bean/user'

  describe("user", ()->

    it("clear user table", (done)->
      user.sql("delete from user where id > 0").then((data)->
        done()
      ).catch(done)
    )

    it("#save", (done)->
      user.save({username: "test", password: "888888"}).then((data)->
        console.log data
        done()
      ).catch(done)
    )

    it("#getByUsernameAndPassword 查找成功测试", (done)->
      user.getByUsernameAndPassword("test", "888888").then((data)->
        (data?).should.be.true
        done()
      ).catch(done)
    )

    it("#getByUsernameAndPassword 查找失败测试", (done)->
      user.getByUsernameAndPassword("test", "888881").then((data)->
        (data?).should.be.false
        done()
      ).catch(done)
    )

    it("#isExistUser 应该存在", (done)->
      user.isExistUser("test").then((count)->
        count.should.eql(1)
        done()
      ).catch(done)
    )

    it("#isExistUser 应该不存在存在", (done)->
      user.isExistUser("test1").then((count)->
        count.should.eql(0)
        done()
      ).catch(done)
    )
  )
)

describe("Http", ()->
  request = require 'request'
  describe("user 用户注册", ()->
    #清空数据库
    it("clear user table", (done)->
      user = require '../bean/user'
      user.sql("delete from user where id > 0").then((data)->
        done()
      ).catch(done)
    )

    it("#post 合法注册， 返回状态码为200", (done)->
      request.post(
        {url: "#{config.server}/user", form: {username: "test", password: "888888", password_repeat: "888888"}},
        (error, resp, body)->
          resp.statusCode.should.eql(200)
          done()
      )
    )

    it("#post 参数错误， 返回状态码为406", (done)->
      request.post(
        {url: "#{config.server}/user", form: {password: "88888"}},
        (error, resp, body)->
          resp.statusCode.should.eql(406)
          done()
      )
    )

    it("#post 用户名重复, 状态码为 205", (done)->
      request.post(
        {url: "#{config.server}/user", form: {username: "test", password: "888888", password_repeat: "888888"}},
        (error, resp, body)->
          resp.statusCode.should.eql(205)
          done()
        )
    )
  )

  describe("user 用户登录获取token", ->

    it("获取成功，状态码 200", (done)->
      request.post(
        {url: "#{config.server}/token", form: {username: "test", password: "888888"}, json: true},
        (error, resp, body)->
          console.log body.private_token
          (body.private_token?).should.be.true
          resp.statusCode.should.eql(200)
          done()
        )
    )

    it("获取失败，状态码 401, 用户名或密码错误", (done)->
      request.post(
        {url: "#{config.server}/token", form: {username: "test", password: "888880"}},
        (error, resp, body)->
          resp.statusCode.should.eql(401)
          done()
      )
    )

    it("获取失败，状态码 403, 用户名被禁止", (done)->
      request.post(
        {url: "#{config.server}/token", form: {username: "test1", password: "888888"}},
        (error, resp, body)->
          resp.statusCode.should.eql(403)
          done()
        )
    )
  )
)

