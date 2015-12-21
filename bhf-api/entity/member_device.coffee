#    Author: 易晓峰
#    E-mail: wvv8oo@gmail.com
#    Date: 6/1/15 9:53 AM
#    Description: 设备与用户的关系

_BaseEntity = require('bijou').BaseEntity
_async = require 'async'
_common = require '../common'

class MemberDevice extends _BaseEntity
  constructor: ()->
    super require('../schema/member_device').schema

module.exports = new MemberDevice