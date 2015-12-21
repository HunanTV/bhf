_async = require 'async'
_common = require '../common'
_uuid = require 'node-uuid'
_path = require 'path'
_fs = require 'fs-extra'
_url = require 'url'
_mime = require 'mime'

#用于simditor编辑器中的上传文件
exports.uploadFile = (req, res, next)->
  project_id = req.params.project_id

  host = req.body.host
  target_dir = _path.join _common.config.uploads, project_id
  #不在则创建这个文件夹
  _fs.ensureDirSync target_dir

  uploadFile = req.files.upload_file
  tempFile = uploadFile.path
  extname = _path.extname(tempFile)
  extname = '.' + _mime.extension(uploadFile.headers['content-type']) if not extname
  filename = _uuid.v4() + extname
  tmp_path = _path.join _common.config.uploadTemporary, _path.basename(tempFile)
  target_path = _path.join target_dir, filename

  #从临时文件夹中移动这个文件到新的目录
  _fs.renameSync(tmp_path, target_path) if _fs.existsSync tmp_path

  absPath = "#{host}/api/project/#{project_id}/attachment/#{filename}"
  res.json file_path: absPath

#读取文件
exports.readFile = (req, res, next)->
  file = _path.join _common.config.uploads, req.params.project_id, req.params.filename
  res.sendfile(file)

exports.toString = -> _path.basename __filename