assert = require 'assert'

redis_config = require("../config").redis

redis = require 'redis'

client = redis.createClient(redis_config.port, redis_config.ip)


describe("Redis", ->

  describe("#set and #get", ->
    it("save key", (done)->
      client.set("abc", 1, done)
    )

    it("get value", (done)->
      client.get("abc", (error, result)->
        return done(error) if error
        result.should.eql("1")
        done()
      )
    )

    it("delete value", (done)->
      client.del("abc", done)
    )

    it("get value after delete shoule be null", (done)->
      client.get("abc", (error, result)->
        return done(error) if error
        (result is null).should.be.true
        done()

      )
    )
  )

  describe("#Save json", ->

    it("should save success", (done)->
      client.set("people", JSON.stringify({a:1}), done)
    )

    it("should get success", (done)->

      client.get("people", (error, result)->
        people = JSON.parse(result)
        people.a.should.eql(1)
        done(error)

      )
    )
  )

  describe("#Save 一次性保存多个值", ->
    it("直接保存json对象", (done)->
      client.mset("a", "1", "b", 2)
      done()
    )

    it("一次性取出1个", (done)->

      client.get("a", (error, result)->
        console.log result
        result.should.eql("1")
        done()
      )

    )

    it("一次性取出1个", (done)->

      client.get("b", (error, result)->
        console.log result
        result.should.eql("2")
        done()
      )

    )
  )

  describe("保存数组", ->
    it("存", (done)->
      client.lpush("message:weixin", JSON.stringify({a:1}))
      client.lpush("message:weixin", JSON.stringify({a:2}))
      done()
    )
    it("取", (done)->
      client.lpop("message:weixin", (error, result)->
        message = JSON.parse(result)
        message.a.should.eql(2)
      )
    )
  )
)