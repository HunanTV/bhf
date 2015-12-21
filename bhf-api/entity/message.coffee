###
  离线消息
###
_BaseEntity = require('bijou').BaseEntity
_async = require 'async'
_common = require '../common'

class Message extends _BaseEntity
  constructor: ()->
    super require('../schema/message').schema

module.exports = new Message