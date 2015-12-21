###
  资产素材
###
_uuid = require 'node-uuid'
_path = require 'path'
_ = require 'lodash'
_mime = require 'mime'
_async = require 'async'
_http = require('bijou').http
_shelljs = require 'shelljs'
_cheerio = require 'cheerio'
_fs = require "fs-extra"

_entity = require '../entity/asset'
_entity_issue = require '../entity/issue'
_commom = require '../common'
_issueBiz = require './issue'
_guard = require './guard'
_imageUtil = require '../utils/image'
_notifier = require '../notification'

#获取文件夹列表
fetchDir = (dir)->
  result = []
  return result if not _fs.existsSync dir
  _fs.readdirSync(dir).forEach (filename)->
    return false if /^\./.test filename

    file = _path.join dir, filename

    #convmv -f GBK -t UTF-8 --notest -r 303i.com/*
    try
      stat = _fs.statSync file
      result.push
        original_name: filename
        file_size: stat.size
        file_type: _mime.lookup filename
        is_dir: stat.isDirectory()
        timestamp: stat.mtime
    catch e
  result

#获取缩略图的路径
getThumbnailPath = (project_id, originFile)->
  dir = _path.join _commom.config.assets, String(project_id), 'thumbnail'
  #缩略图的扩展名都是png
  filename = _commom.removeExt(originFile) + '.png'
  _path.join dir, filename

getAssetPath = (project_id, originFile)->
  _path.join _commom.config.assets, String(project_id), originFile

##生成缩略图
#thumbnailGenerator = (source, cb)->
#  extname = _path.extname(source)
#  return if not /^\.(png|jpg|gif|bmp)$/i.test(extname)
#
#  rawFileName = _commom.removeExt(_path.basename(source))
#  #存储缩略图的文件夹
#  thumbnailPath = _path.join(_path.dirname(source), 'thumbnail')
#  #不在则创建这个文件夹
#  _commom.dirPromise thumbnailPath
#  thumbnailFile = _path.join thumbnailPath, rawFileName + '.png'
#
#  _imageUtil.resize source, thumbnailFile, _commom.config.thumbnail, cb

#保存文件
saveAsset = (tempFile, project_id, cb)->
  target_dir = _path.join _commom.config.assets, project_id
  #不在则创建这个文件夹
  _fs.ensureDirSync target_dir
  #_fs.mkdirSync target_dir if not _fs.existsSync target_dir
  #文件的uuid
  fileUUID = _uuid.v4()
  #文件的扩展名
  fileExtname = _path.extname(tempFile)
  #保存时的文件名
  filename = fileUUID + fileExtname
  tmp_path = _path.join _commom.config.uploadTemporary, _path.basename(tempFile)
  target_path = _path.join target_dir, filename

  #从临时文件夹中移动这个文件到新的目录
  _fs.renameSync(tmp_path, target_path) if _fs.existsSync tmp_path
  cb null, filename


#解压缩文件
uncompress = (bundleFile, releaseFile, cb)->
  return unrar bundleFile, releaseFile, cb if /\.rar$/.test bundleFile
  spawn = require('child_process').spawn
  exec = spawn("7za", ["x", bundleFile, "-o#{releaseFile}", "-y"])
  exec.stdout.on 'data',  (data)-> _commom.log('stdout: ' + data);
  exec.stderr.on 'data', (data)-> _commom.log('stderr: ' + data);
  exec.on 'close',  (code)-> cb code

#  extname = _path.extname bundleFile
#  switch extname
#    when '.zip' then unzip bundleFile, releaseFile, cb
#    when '.rar' then unrar bundleFile, releaseFile, cb
#    else cb new _commom.Error406('未知压缩包文件格式')


#解压缩rar文件
unrar = (bundleFile, releaseFile, cb)->
  _fs.ensureDirSync releaseFile
  spawn = require('child_process').spawn
  exec = spawn("unrar", ['x', bundleFile, releaseFile])
  exec.stdout.on 'data',  (data)-> _commom.log('stdout: ' + data);
  exec.stderr.on 'data', (data)-> _commom.log('stderr: ' + data);
  exec.on 'close',  (code)->
    _commom.log "解压缩rar: #{bundleFile}，code：#{code}"
    cb null

#解压缩文件
unzip = (bundleFile, releaseFile, cb)->
  #_fs.ensureDirSync releaseFile
  spawn = require('child_process').spawn
  exec = spawn("unzip", [bundleFile, "-d", releaseFile])
  #exec.stdout.on 'data',  (data)-> console.log('stdout: ' + data);
  #exec.stderr.on 'data', (data)-> console.log('stderr: ' + data);
  exec.on 'close',  (code)-> cb null

#读取zip文件中的文件
fetchZipDir = (releasePath, subdir, cb)->
  baseDir = releasePath.replace _commom.config.assets, ''
  target = _path.join releasePath, subdir
  files = fetchDir(target)
  _.each files, (item)->
    item.url = _path.join("/api/assets/#{baseDir}/#{subdir}/#{item.original_name}") if not item.is_dir
  cb null, files

#读取压缩文件，如果是还没有解压缩，则先解压
readBundleFile = (project_id, zipfile, subdir, cb)->
  bundleFile = _path.join _commom.config.assets, project_id, zipfile

  #一定要找到bundleFile，否则返回错误
  return cb(null, []) if not _fs.existsSync bundleFile

  #文件已经存在，则直接读取文件
  releasePath = _commom.removeExt(bundleFile)
  return fetchZipDir releasePath, subdir, cb if _fs.existsSync releasePath

  #解压缩文件
  uncompress bundleFile, releasePath, (err)->
    return cb err if err
    #convmv -f GB2312 -t UTF-8 --notest -r *
    #转码
    spawn = require('child_process').spawn
    #cmd = "cd #{releasePath} && convmv -f GB2312 -t UTF-8 --notest -r *"
    exec = spawn("convmv", ["-f", "GB2312", "-t", "UTF-8", "--notest", "-r", "#{releasePath}"])
    #exec = spawn("cd #{releasePath} && convmv -f GB2312 -t UTF-8 --notest -r *")
    exec.stdout.on 'data',  (data)-> console.log('stdout: ' + data);
    exec.stderr.on 'data', (data)-> console.log('stderr: ' + data);
    exec.on 'close',  (code)-> fetchZipDir(releasePath, subdir, cb)


#检查文件是否为压缩包
isBundle = (file)->
  _path.extname(file) in ['.zip', '.rar', '7z']

#删除素材，不做任何权限校验
removeAsset = (project_id, asset_id, cb)->
  asset = null
  queue = []
  #获取asset_id的数据
  queue.push(
    (done)-> _entity.findById asset_id, (err, result)->
      asset = result
      done err
  )

  #删除文件
  queue.push(
    (done)->
      return done _http.notFoundError() if not asset
      #全文件名
      file = _path.join _commom.config.assets, project_id, asset.file_name
      #删除
      _fs.unlinkSync file if _fs.existsSync file

      return done null if isBundle file

      #如果是zip及rar文件，则删除缓存文件
      cache = _commom.removeExt file
      _fs.unlinkSync cache  if _fs.existsSync cache
      done null
  )

  #删除数据库
  queue.push(
    (done)-> _entity.removeById asset_id, (err)-> done err
  )

  #记录到日志中
  queue.push(
    (done)->
      #没有指定issue_id的，不用记录日志
      return done null if not asset.issue_id

      logContent = "删除附件->##{asset.id}->#{asset.original_name}"
      _issueBiz.writeLog asset.creator, asset.issue_id, logContent
      done null
  )

  _async.waterfall queue, cb




#解析doc文档并自动创建任务
exports.splitDocToIssue= (req, res, next, client)->
  project_id = req.params.project_id
  version_id = req.params.version_id
  category_id = req.params.category_id
  
  asset = req.files.assets

  target_dir = _path.join _commom.config.uploads, project_id

  _fs.ensureDirSync target_dir
  
  queue = []


  #必需要是项目中的成员，才能创建
  # queue.push(
  #   (done)->
  #     return done null if _guard.projectIsService project_id
  #     _guard.projectPermission project_id, client.member, '*-g', (err)-> done err
  # ) 


  #上传docx
  queue.push(
    (done)->
      #复制文件到新的目录
      saveAsset asset.path, project_id, (err, filename)->
        done err, filename
  ) 

  # queue.push(
  #   (done)->
  #     _entity.findById asset_id, (err, asset)->
  #       err = _http.notFoundError() if not asset
  #       done err, asset
  # )

  queue.push(
    (filename, done)->
      file = getAssetPath project_id, filename
      # return done _http.notAcceptableError('只支持.docx文件') if not /^\.docx$/i.test(filename)

      _shelljs.exec "unoconv --stdout --format=html #{file}", silent: true, (code, content)->
          # absPath = "#{host}/api/project/#{project_id}/attachment/#{filename}"
          $ = _cheerio.load content
          combineIssueContent = ($this)->

            return if !$this[0] || $this[0].name is "ol"
            content_temp += $this.html() 
            combineIssueContent $this.next()

          issue_list = []
          content_temp = ""

          $('ol').each (i)->
            if $(this).find('li').length is 1
              content_temp = $(this).html()
              combineIssueContent $(this).next()
              issue_list.push 
                content: content_temp
                title: $(this).find('li p').eq(0).text()
            else
              $(this).find('li').each ()->
                issue_list.push 
                  content: $(this).html()
                  title: $(this).find('p').eq(0).text()


          done null, issue_list

  )

  queue.push(
    (issue_list, done)->
      makeIssue = (issue)->
        issue.project_id = project_id
        issue.version_id = version_id
        issue.category_id = category_id
        issue.creator = req.session.member_id
        issue.timestamp = Number(new Date())
        issue.priority = 3
        issue.status = 'new'
        issue.tag = 'issue'
        issue.always_top = false
      makeIssue(issue) for issue in issue_list
      _entity_issue.addIssues issue_list,(err, result)->
        done err, result

  )
  _async.waterfall queue, (err,result)->
    _http.responseJSON err, id: result, res
    return if err or not result


  # _shelljs.exec "unoconv --stdout --format=html ~/Downloads/音乐频道首页问题.docx", silent: true, (code, content)->

  #   # absPath = "#{host}/api/project/#{project_id}/attachment/#{filename}"
  #   _fs.writeFile (_path.join target_dir, 'out.html'), content
  #   $ = _cheerio.load content

  #   combineIssueContent = ($this)->
  #     return if $this[0].name is "ol"
  #     content_temp += $this.html() 
  #     combineIssueContent $this.next()

  #   issue_list = []
  #   content_temp = ""

  #   console.log 'start'
  #   $('ol').each (i)->
  #     if $(this).find('li').length is 1
  #       content_temp = $(this).html()
  #       combineIssueContent $(this).next()
  #       issue_list.push 
  #         issue_content: content_temp
  #         issue_title: $(this).find('li p').eq(0).text()
  #     else
  #       $(this).find('li').each ()->
  #         issue_list.push 
  #           issue_content: $(this).html()
  #           issue_title: $(this).find('p').eq(0).text()


  #   console.log issue_list


    # $('img').each (i)->

    #   data = new Buffer $(this).attr('src').split(',')[1], 'base64'

    #   filename = _uuid.v4() + '.jpg'
    #   target_path =s _path.join target_dir, filename

    #   _fs.writeFile target_path, data,()->
    

#展开自解压文件
exports.unwind = (client, cb)->
  project_id = client.params.project_id
  asset_id = client.params.asset_id
  subdir = client.query.subdir || ''

  queue = []
  queue.push(
    (done)->
      _entity.findById asset_id, (err, result)->
        return done err if err

        if not (result and /\.(zip|rar|7z|tar)$/i.test(result.file_name))
          return done _http.notFoundError()

        done null, result.file_name
  )

  _async.waterfall queue, (err, zipfile)->
    return cb err if err
    readBundleFile project_id, zipfile, subdir, (err, result)->
      return cb _http.notAcceptableError('解压缩文件失败，请直接下载文件') if err

      _.map result, (item)->
        item.project_id = project_id
        item.id = asset_id
      cb err, result

#获取素材
exports.get = (client, cb)->
  asset_id = client.params.id
  # project_id = client.params.project_id
  #获取单条数据
  return _entity.findById asset_id, cb if asset_id

  #读取所有素材
  cond =
    # project_id: project_id
    issue_id: client.params.issue_id
    keyword: client.query.keyword

  pagination = _entity.pagination client.query.pageIndex, client.query.pageSize

  _entity.fetch cond, pagination, (err, result)->
    _.each result.items, (item)->
      item.url = _commom.assetUrl item.project_id, item.file_name

    cb err, result


#特殊方法，读取文件
exports.readAsset = (req, res, next, client)->
#  project_id = client.params.project_id
  asset_id = client.params.asset_id

  queue = []
  queue.push(
    (done)->
      _entity.findById asset_id, (err, asset)->
        err = _http.notFoundError() if not asset
        done err, asset
  )

  _async.waterfall queue, (err, asset)->
    return _http.responseError err, res if err

    filename = asset.file_name
    file = getAssetPath asset.project_id, filename
    digZip = isBundle(asset.original_name) and client.query.dig
    if digZip
      file = _path.join _commom.removeExt(file), client.query.dig || ''

    return _http.responseNotFound res if not _fs.existsSync file

#    #下载文件
    if client.query.download is 'true'
      downloadFile = asset.original_name
      #如果是挖掘zip文件，则直接取文件名就可以了
      downloadFile = _path.basename file if digZip
#      ‘Content-Disposition’: "attachment;filename*=UTF-8’’"+urlencode(‘你好！’)+’.txt’
#      res.setHeader 'Content-Type', 'application/octet-stream;charset=utf8'
#      res.setHeader('Content-disposition', "attachment; filename=UTF-8\"#{encodeURIComponent(downloadFile)}\"")

      #设置下载文件的问题
      userAgent = (req.headers["user-agent"] or "").toLowerCase()
      if userAgent.indexOf("msie") >= 0 or userAgent.indexOf("chrome") >= 0
        res.setHeader "Content-Disposition", "attachment; filename=" + encodeURIComponent(downloadFile)
      else if userAgent.indexOf("firefox") >= 0
        res.setHeader "Content-Disposition", "attachment; filename*=\"utf8''" + encodeURIComponent(downloadFile) + "\""
      else

        # safari等其他非主流浏览器只能自求多福了
        res.setHeader "Content-Disposition", "attachment; filename=" + new Buffer(downloadFile).toString("binary")
    else
      res.setHeader 'Content-type', _mime.lookup(file)

    res.sendfile file

#读取缩略图
exports.thumbnail = (req, res, next, client)->
  project_id = client.params.project_id
  asset_id = client.params.asset_id

  queue = []
  queue.push(
    (done)->
      cond = project_id: project_id, id: asset_id
      _entity.findOne cond, (err, result)->
        err = _http.notFoundError() if not result
        done err, result
  )

  #获取缩略图，如果不存在，则生成缩略图
  queue.push(
    (asset, done)->
      thumbnailFile = getThumbnailPath(asset.project_id, asset.file_name)
      #文件存在，则直接返回
      return done null, thumbnailFile if _fs.existsSync thumbnailFile

      #没有这个文件，实时创建缩略图

      #获取大图
      originFile = getAssetPath asset.project_id, asset.file_name

      #检查扩展名，如果扩展名不是图片，则返回notFound
      extname = _path.extname(originFile)
      return done _http.notAcceptableError('只有图片才有缩略图') if not /^\.(png|jpg|gif|bmp)$/i.test(extname)
      return done _http.notFoundError() if not _fs.existsSync originFile

      #检查是否要创建文件夹
      thumbnailPath = _path.dirname thumbnailFile
      _fs.ensureDirSync thumbnailPath

      cfg = _commom.config.thumbnail
      _imageUtil.resize originFile, thumbnailFile, cfg, (err)->
        done err, thumbnailFile
  )

  _async.waterfall queue, (err, thumbnailFile)->
    return _http.responseError err, res if err
    res.sendfile thumbnailFile

#特殊方法，处理上传文件
exports.uploadFile = (req, res, next, client)->
  project_id = req.params.project_id
  issue_id = req.params.issue_id || 0
  asset = req.files.assets

  #复制文件到新的目录
  saveAsset asset.path, project_id, (err, filename)->
    data =
      file_name: filename
      file_size: asset.size
      file_type: asset.type
      project_id: project_id
      issue_id: issue_id
      timestamp: Number(new Date())
      creator: client.member.member_id
      original_name: asset.originalFilename

    _entity.save data, (err, asset_id)->
      _http.responseJSON err, id: asset_id, res
      return if err or not data.issue_id
      #仅记录上传到issue下的日志
      logContent = "上传附件->#{data.original_name}"
      _issueBiz.writeLog data.creator, data.issue_id, logContent

      data.id = asset_id
      _notifier.addAsset data

#称除素材
exports.remove = (client, cb)->
  project_id = client.params.project_id
  asset_id = client.params.id

  #请求删除的权限
  _guard.allowRemoveAsset project_id, asset_id, client.member, (err, allow)->
    return cb err if err

    removeAsset project_id, asset_id, cb

exports.toString = -> _path.basename __filename