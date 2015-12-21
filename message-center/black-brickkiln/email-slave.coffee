_ = require 'lodash'
_request = require 'request'
_Slave = require './slave'
_config = require '../config'
_Log = require '../log'
_key = _config.message.email
#调用 http://git.hunantv.com/arch/ses/wikis/home 接口
_ses = _config.ses

class EmailSlave extends _Slave
  constructor: (@event)->
    @type = "email"
    @key = _key
    @initCall()

  send: (data, done)->
    msg = data.msg
    self = @
    params = @standardEMail(msg)
    option =
      url: _ses.url
      form: params
      json: true
    _request.post(option, (error, resp, body)->
      if error
        self.dealErrorMessage(data)
      else if body and body.code isnt 0
        #邮件格式有错，直接存日志
        self.saveErrorMessageDoNotTryAgain(data)
      else if (not resp) or resp.statusCode isnt 200
        _Log.error(body)
      done(null, data.msg)
    )

  standardEMail: (msg)->
    params = _.extend({}, _ses.params)

    params.SES_address = msg.to
    params.SES_title = msg.subject or "无标题"
    params.SES_content = msg.text or " "
    params

module.exports = EmailSlave