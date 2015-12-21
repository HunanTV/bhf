assert = require 'assert'
config = require './config'
_ = require 'lodash'

describe("Database", ()->
  log = require '../bean/log'
  _Log = require '../log'

  describe("log", ()->

    it("clear log table", (done)->
      log.sql("delete from log where id > 0").then((data)->
        done()
      ).catch(done)
    )

    it("#save", (done)->
      log.save({uid: "test", api: "/api/asdsad"}).then((data)->
        console.log data
        done()
      ).catch(done)
    )
  )
)