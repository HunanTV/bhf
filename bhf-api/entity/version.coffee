###
  版本
###
_BaseEntity = require('bijou').BaseEntity
_async = require 'async'
_common = require '../common'

class VersionCategory extends _BaseEntity
  constructor: ()->
    super require('../schema/version').schema

module.exports = new VersionCategory