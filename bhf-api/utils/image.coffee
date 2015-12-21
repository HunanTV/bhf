_gm = require 'gm'
_ = require 'lodash'
_fs = require 'fs-extra'

#处理缩略图
exports.resize = (source, target, options, cb)->
  ops = _.extend {
    quality: 1,
    width: 100,
    height: 100
  }, options

  _gm(source).thumbnail(ops.width, ops.height)
    .write(target, (err)->
      cb? err
    )

  ###
  #如果图片本来就很小，则不处理
  _im.identify source, (err, stat)->
    console.log err
    #图片太小不用处理
    if stat.width < ops.width and stat.height < ops.height
      _fs.copySync source, target
      cb? null
    else
      _im.resize ops, (err, stdout, stderr)->
        console.log stdout
        console.log stderr
        cb? err
  ###