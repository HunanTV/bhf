###
  团队
###

_util = require 'util'
_bijou = require('bijou')
_BaseEntity = _bijou.BaseEntity
_http = _bijou.http
_common = require '../common'

class Team extends _BaseEntity
  constructor: ()->
    super require('../schema/team').schema

module.exports = new Team
