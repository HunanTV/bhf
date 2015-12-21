###
  包工头
###

path = require 'path'
child_process = require('child_process')

blackBrickkilnPath = path.join(process.cwd(), "black-brickkiln")

EventEmitter = require('events').EventEmitter

class Supervisor
  constructor: (@slaveType, slaveCount = 1)->
    @event  =  new EventEmitter()
    #召唤奴隶啦
    for i in [1..slaveCount]
      @initSlave(@slaveType, @event)

  #发布命令了
  startWork: -> @event.emit("supervisor:#{@slaveType}:work")

  #初始化奴隶
  initSlave: (type, event)->
    slaveAddress = path.join(blackBrickkilnPath, "#{type}-slave")
    Slave = require(slaveAddress)
    new Slave(event)

  isExistsSlaveType: (type)->
    return true if fs.existsSync(path.join(blackBrickkilnPath, "#{type}-slave.js"))
    return true if fs.existsSync(path.join(blackBrickkilnPath, "#{type}-slave.coffee"))
    return false

module.exports = Supervisor