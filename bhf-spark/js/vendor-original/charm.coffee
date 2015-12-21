###
  用更优雅的方式调用RESTful APIs
  Author: wvv8oo
  Github: https://github.com/wvv8oo/charm.js
###
(->
  #url中的节点实体
  class SegmentEntity
    constructor: (@parent, @segmentModel)->
      @params = []
      #创建实体时更新成员
      @_updateProperties()
      @_addMethods()

    #添加方法
    _addMethod: (verb, funcName)->
      self = @
      @[funcName] = (data, cb)->
        if typeof data is 'function'
          cb = data
          data = {}

        self._doAction verb, data, cb

    #批量添加方法
    _addMethods: ->
      map = post: 'create', put: 'update', patch: 'patch', delete: 'delete', get: 'retrieve', jsonp: 'jsonp'
      methods = @segmentModel.options.methods || map

      @_addMethod funcName, method for funcName, method of methods

    #添加字符与数字形式的param
    _addPlainParam: (param, index)->
      placeholder = @segmentModel.placeholders[index]
      return if not placeholder
      @params[index] = key: placeholder.key, value: String(param)

    #添加对象类型的参数
    _addObjectParam: (param)->
      for key, value of param
        #找到key对应的索引位置
        findIndex = -1
        for item, index in @segmentModel.placeholders
          if item.key is key
            findIndex = index
            break

        @_addPlainParam value, findIndex

    #添加params
    _addParams: (params)->
      for param, index in params
        if typeof param in ['string', 'number']
          @_addPlainParam param, index
        else
          @_addObjectParam param

    _currentToString: ()->
      url = @segmentModel.name

      #检查是否包括参数
      for param in @params
        url += "/#{param.value}" if param.value

      url

    #提取segment对应的访问我
    _extractMethodName: (name)->
      return name if @segmentModel.options.rawMethodName

      name = name.replace /[\-](\w)/, (m, n)-> n.toUpperCase()
      return name

    #更新实例成员
    _updateProperties: ()->
      for child in @segmentModel.children
        method = @_extractMethodName(child.name)
        #跳过已经存在的方法
        continue if @[method]

        @[method] = SegmentEntity.create @, child

    #执行操作
    _doAction: (method, data, cb)->
      q = @segmentModel.options.promise
      ajax = @segmentModel.options.ajax

      url = @toString()
      #没有指定promise的情况下，直接调用ajax
      return ajax(url, method, data, cb) if not q

      #如果指定了promise，则使用promise的方式
      deferred = q.defer()
      ajax(url, method, data, ((result)->
          deferred.resolve result
        ), (result)->
        deferred.reject result
      )

      deferred.promise

    #添加url
    parse: (urls)->
      @segmentModel.parse urls
      @_updateProperties()

    #转换为字符串式的url
    toString: (ignoreSuffix)->
      return '' if not @parent
      ops = @segmentModel.options
      url = @parent?.toString(true) || ops.prefix || ''
      url += "/#{@_currentToString()}"
      url += ops.suffix if not ignoreSuffix and ops.suffix
      url

  #根据model，创建一个实体
  SegmentEntity.create = (parent, segmentModel)->
    (args...)->
      entity = new SegmentEntity(parent, segmentModel)
      entity._addParams args
      entity

  #url中的节点模型
  class SegmentModel
    constructor: (@parent, @name, @options)->
      @children = []
      #url中的参数
      this.placeholders = []

    #转换一个api
    parseUrl: (api)->
      parent = @
      url = api.url || api
      for part in url.split('/')
        parent = parent.addChild part

    #添加网址
    parse: (apis)->
      apis = [apis] if not(apis instanceof Array)
      @parseUrl api for api in apis

    setPlaceholders: (value, index)->
      #批量添加占位符
      return @addPlaceholders value if typeof value is 'object'

    #添加点位符
    addPlaceholder: (identifier)->
      @placeholders.push key: identifier

    #添加子节点
    addChild: (part)->
      #如果以冒号开头，则添加到urlParam中作为占位符
      if /^:.+/.test part
        @addPlaceholder part.substr 1
        return @

      #查找节点，或者创建新的节点
      for child in @children
        return child if child.name is part

      @createSegmentModel(part)


    #创建子segment
    createSegmentModel: (part)->
      segment = new SegmentModel(@, part)
      segment.options = @options
      @children.push segment
      segment


  #默认使用jQuery的ajax
  jQueryAjax = (url, type, data, cb)->
    #如果没有设置ajax参数，且没有引用jQuery，则提示错误
    return console.error '请设置options.ajax参数或引用jQuery' if not $?.ajax

    dataType = if type is 'jsonp' then 'JSONP' else 'JSON'
    type = 'GET' if type is 'jsonp'
    $.ajax url,
      type: type
      data: data
      dataType: dataType
      success: (response)-> cb? response

  charm = (options)->
    options = options || {}
    options.ajax = options.ajax || jQueryAjax
    #创建一个root
    model = new SegmentModel(null, null, options)
    entity = new SegmentEntity(null, model)
    return entity


  if typeof define is 'function'
    define [], -> charm
  else if typeof exports is "object"
    module.exports = charm
  else
    window.charm = charm
)()