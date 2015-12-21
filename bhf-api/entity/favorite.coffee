_BaseEntity = require('bijou').BaseEntity
_async = require 'async'
_ = require 'lodash'

class Favorite extends _BaseEntity
  constructor: ()->
    super require('../schema/favorite').schema

module.exports = new Favorite