BaseBean = require './base'

class Log extends BaseBean
  constructor: (tablename)->
    super

module.exports = new Log('log')