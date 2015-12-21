_fs = require 'fs'
_common = require '../common'
_path = require 'path'

(->
  _fs.readdirSync(__dirname).forEach (filename)->
    return if not /coffee$/.test filename or /^index\./.test filename
    key = _common.removeExt(filename)
    module.exports[key] = require _path.join(__dirname, filename)
)()
