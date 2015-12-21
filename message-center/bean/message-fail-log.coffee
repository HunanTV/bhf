BaseBean = require './base'
class MessageFailLog extends BaseBean
  constructor: (tablename)->
    super

module.exports = new MessageFailLog("message_fail_log")