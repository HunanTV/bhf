###
  invite
###
_BaseEntity = require('bijou').BaseEntity
_async = require 'async'
_common = require '../common'

class Invite extends _BaseEntity
  constructor: ()->
    super require('../schema/invite').schema

module.exports = new Invite