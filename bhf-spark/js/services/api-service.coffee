"use strict"
define [
  'ng'
  '../ng-module'
  'v/charm'
  'utils'
  '../apis'
], (_ng, _module, _charm, _utils, _api) ->
  BASEAPI = '/api/'

  _module.serviceModule
  .factory('API', ['$http', '$location', '$q', 'NOTIFY', '$sce', '$rootScope', 'LOADING'
  ($http, $location, $q, NOTIFY, $sce, $rootScope, LOADING)->

    options =
      prefix: '/api'
      promise: $q
      ajax: (url, method, data, success)->
        ajaxOps = url: url, method: method
        if method.toLowerCase() in ['post', 'put', 'patch']
          ajaxOps.data = data
        else
          ajaxOps.params = data

        $http(ajaxOps).success(success).error((data, status) ->
          LOADING.loaded()
          switch status
            when 404
              NOTIFY.error "404 Not Found"
            when 500
              NOTIFY.error "大事不好了，服务器发生错误啦"
            when 406
              message = data.message or data
              NOTIFY.error "提示：" + message
            when 403
              message = data.message or data
              NOTIFY.error "你没有权限操作此项功能"
            when 401
              $location.path('/login')
            when 413
              NOTIFY.error "呐什么，文件好象太大了点..."
            else
            #以后再考虑不同的处理
              console.error "未知错误"
        )


    router = _charm(options)
    ###
    router.parse('apis')
    router.apis().retrieve().then (result)->
      router.parse result
      $rootScope.$broadcast 'api:ready'
    ###
    router.parse _api

    #获取jsonp的数据
    oldAjax = (ajaxOps)->
      console.warn "警告：此方法已经停用，请使用charm.js调用API，#{ajaxOps.url}"
      #如果没有baseUrl，则加上
      ajaxOps.url = "#{options.prefix}/#{ajaxOps.url}" if ajaxOps.url.indexOf(options.prefix) < 0
      deferred = $q.defer()
      options.ajax(ajaxOps.url, ajaxOps.method, ajaxOps.data || ajaxOps.params, (result)->
        deferred.resolve result
      )

      deferred.promise

    #兼容旧数据，以后需要删除这些代码
    router.get = (url, params)-> oldAjax url: url, params: params, method: 'GET'
    router.post = (url, data)-> oldAjax url: url, data: data, method: 'POST'
    router.delete = (url, params)-> oldAjax url: url, params: params, method: 'DELETE'
    router.put = (url, id, data)->
      #如果第二个参数为number，则将id加到url后面
      if typeof(id) is 'number'
        url += "/#{id}"
      else
        data = id

      oldAjax url: url, data: data, method: 'PUT'

    router.save = (url, data)->
      if data.id
        url = "#{url}/#{data.id}"
        delete data.id

      oldAjax url: url, data: data


    return router
    ###
    api =
      #获取jsonp的数据
      ajax: (options)->
        #如果没有baseUrl，则加上
        options.url = "#{BASEAPI}#{options.url}" if options.url.indexOf(BASEAPI) < 0
        deferred = $q.defer()
        $http(options).success((result)->
          deferred.resolve result
        ).error((data, status) ->
          switch status
            when 404
              NOTIFY.error "找不到文件啦"
            when 500
              NOTIFY.error "大事不好了，服务器发生错误啦"
            when 406
              message = data.message or data
              NOTIFY.error "提示：" + message
            when 403
              message = data.message or data
              NOTIFY.error "你没有权限操作此项功能"
            when 401
              $location.path('/login')
            else
            #以后再考虑不同的处理
              NOTIFY.error "未知错误"

          deferred.reject null
        )

        deferred.promise

    #这段代码可以考虑优化一下
      get: (url, params)-> @ajax url: url, params: params
      post: (url, data)-> @ajax url: url, data: data, method: 'post'
      delete: (url, params)-> @ajax url: url, params: params, method: 'delete'
      put: (url, id, data)->
        #如果第二个参数为number，则将id加到url后面
        if typeof(id) is 'number'
          url += "/#{id}"
        else
          data = id

        @ajax url: url, data: data, method: 'put'

      save: (url, data)->
        if data.id
          url = "#{url}/#{data.id}"
          delete data.id

        @ajax url: url, data: data

    api
    ###
  ])