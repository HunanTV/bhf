class Log
  constructor: ->

  info: (msg)-> console.log msg

  warn: (msg)-> console.warn msg

  debug: (msg)-> console.log "[DEBUG]  ", msg

  error: (error)-> console.error(error)

module.exports = new Log()