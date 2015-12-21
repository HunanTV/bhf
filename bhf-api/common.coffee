###
  工具类
###
_path = require 'path'
_crypto = require 'crypto'
_fs = require 'fs-extra'
_events = require 'events'
_ = require 'lodash'

ENVISDEV = (->process.env.NODE_ENV is 'development')()
WORKSPACE = "./config/#{process.env.NODE_ENV || 'development'}"
_config = require WORKSPACE
_util = require 'util'
_mime = require 'mime'
_pageEvent = new _events.EventEmitter()

#触发事件
exports.trigger = (name, arg...)-> _pageEvent.emit(name, arg)

#监听事件
exports.addListener = (event, listener)-> _pageEvent.addListener event, listener

exports.removeListener = (event, listener)-> _pageEvent.removeListener event, listener

#获取一个正确的路径，允许相对或者绝对路径
exports.storagePath = (key)->
  relativePath = _path.join _config.storage.base, _config.storage[key]
  _path.join __dirname, _path.relative(__dirname, relativePath)

#处理一下路径
_config.assets = exports.storagePath 'assets'
_config.uploads = exports.storagePath 'uploads'
_config.uploadTemporary = exports.storagePath 'uploadTemporary'

console.log "Workspace -> #{WORKSPACE}"
console.log "Uploads -> #{_config.uploads}"
console.log "uploadTemporary -> #{_config.uploadTemporary}"

exports.log = (log, type)->
  return if not ENVISDEV
  console.log log

exports.config = _config
#获取程序的主目录
exports.rootPath = _path.dirname(require.main.filename)

exports.md5 = (text)->
  md5 = _crypto.createHash('md5')
  md5.update(text)
  md5.digest('hex')

#移除扩展名
exports.removeExt = (filename)-> filename.replace /\.\w+/, ''

#过滤掉着头尾的空格
exports.trim = (text)->
  text = text.replace(/^\s*(.+?)\s*$/, "$1") unless text
  text

#检查tag
exports.checkTag = (tag)->
  if tag in ['test', 'document', 'discussion', 'issue', 'wiki', 'form'] then tag else 'issue'

#检查是否为合法的版本状态
exports.validVersionStatus = (status)->
  status in ['archive', 'active', 'deactive']

#状态只能是这几种
exports.checkStatus = (status)->
  if status in ['doing', 'done', 'pause', 'trash'] then status else 'doing'

exports.checkPriority = (priority)-> priority in [1..5]
#检查用户的权限是否合法
exports.memberRoleValidator = (role)-> if 'aum'.indexOf(role) >= 0 then role else 'u'

#检查项目权限是否合法
exports.projectRoleValidator = (role)-> if 'ldptg'.indexOf(role) >= 0 then role else 'g'

#构造issue的链接
exports.issueLink = (project_id, issue_id, linkOnly)->
  link = "#{_config.host}project/#{project_id}/issue/#{issue_id}"
  return link if linkOnly
  "<a href='#{link}' target='_blank'>点击查看</a>"
#返回invite的链接
exports.inviteLink = (linkOnly)->
  link = "#{_config.host}team/0/invite?title=我的邀请"
  return link if linkOnly
  "<a href='#{link}' target='_blank'>点击查看</a>"

exports.formatString = (text, args...)->
  return text if not text
  #如果第一个参数是数组，则直接使用这个数组
  args = args[0] if args.length is 1 and args[0] instanceof Array
  text.replace /\{(\d+)\}/g, (m, i) -> args[i]

#提取提及某人
exports.extractMention = (filter, args...)->
  names = []
  pattern = /@(.{1,10}?)(\s|<|$)/g
  #如果filter不是数组，则将filter扔到args中作为普通字符对待
  #filter如果是数组，则过滤掉某些@，比如说没有权限的人@all，则可以用 extractMention ['all'], content
  if not(filter instanceof Array)
    args.push filter
    filter = []

  for arg in args
    continue if not arg
    arg.replace pattern, (a, nane)-> names.push nane

  #去重并过滤
  _.difference _.uniq(names), filter

#清除对象中的undefined
exports.cleanUndefined = (hash)->
  (delete hash[key] if value is undefined) for key, value of hash
  hash

exports.statusDescription = (status)->
  {
    doing: '进行中'
    done: '已完成/产品已审'
    repairing: '修复中'
    repaired: '已修复'
    pause: '暂停'
    reviewing: '测试已审'
    trash: '删除'
  }[status] || '未知状态'

#移掉html中的标签
exports.html2text = (html)->
  return html if not html
  html.replace(/<br\s?\/?>/ig, '\n')
    .replace(/&nbsp;/ig, ' ')
    .replace(/<\/?[^>]*>/g, '')
    .replace(/[ | ]* /g, ' ')
    .replace(RegExp(' ', 'gi'), '')
#    .replace(/ [\s| | ]* /g,' ')

#枚举
exports.enumerate =
  gitMapType:
    project: "project"
    member: "member"
  projectFlag:
    wiki: 1
    service: 2
    normal: 0
  streamEventName:
    assetPost: 'issue:asset:post'
    commentPost: 'issue:comment:post'
    issueAssigned: 'issue:assigned'
    mention: 'issue:mention'
    invitation: 'team:invitation'
    statusChange: 'issue:status:change'

#安全转换JSON
exports.parseJSON = (text)->
  return {} if not text or typeof(text) isnt 'string'
  JSON.parse text

exports.assetUrl = (project_id, file_name)->
  "/api/assets/#{project_id}/#{file_name}"