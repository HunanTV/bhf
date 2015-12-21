async = require 'async'
Log = require '../log'
_FailLog = require '../bean/message-fail-log'
redisClient = require('../db-connect').redis_conn()
config = require '../config'
_tryCount = config.tryCount
class Slave
  constructor: ->

  work: ->
    self = @
    self.isWorking = true
    queue = []
    queue.push((done)->
      redisClient.lpop(self.key, (error, result)->
        return done(error) if error
        #工作完成，不需要进行下一步了
        if not result
          self.isWorking = false
          return done(null, null)
        done(null, JSON.parse(result))
      )
    )

    queue.push((message, done)->
      return done(null, null) if not message
      self.send(message, done)
    )

    async.waterfall(queue, (error, message)->
      Log.error(error) if error
      self.work() if message
    )

  #是否正在工作
  isWorking: false

  #怕错过了工头训话
  initCall: ->
    self = @
    @event.on("supervisor:#{self.type}:work", (e)->
      self.work() if not self.isWorking
    )

  dealErrorMessage: (data)->
    self = @
    if data.count < _tryCount
      data.count = data.count + 1
      redisClient.lpush(self.key, JSON.stringify(data), ->
        self.work() if not self.isWorking
      )
    else
      _FailLog.save({type: self.type, body: JSON.stringify(data)}).then(()->)

  saveErrorMessageDoNotTryAgain: (data)->
    _FailLog.save({type: self.type, body: JSON.stringify(data)}).then(()->)

module.exports = Slave
