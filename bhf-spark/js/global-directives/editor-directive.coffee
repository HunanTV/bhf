define [
  '../ng-module'
  'utils'
  'simditor'
], (_module, _utils, _simditor) ->
  _module.directiveModule.directive('editor', ['$location', '$timeout', 'STORE','EDITORSTORE',
  ($location, $timeout, STORE,EDITORSTORE)->
    restrict: 'E'
    replace: true
    scope: {}
    templateUrl: '/views/editor.html'
    link: (scope, element, attrs)->
      simditor = null
      currentUUID = null

      #初始化编辑器
      ensureEditor = (uploadUrl, cb)->
        return cb(simditor) if simditor

        options =
          textarea: $(element).find('textarea')
          pasteImage: true
  #       defaultImage: 'images/image.png'
          params: {}
          upload:
            params: host: "#{$location.protocol()}://#{$location.host()}:#{$location.port()}"
            url: uploadUrl
            connectionCount: 3
            leaveConfirm: '正在上传文件，如果离开上传会自动取消'
          tabIndent: true
          toolbar: [
            'title'          # 标题文字
            'bold'           # 加粗文字
            'italic'         # 斜体文字
            'underline'      # 下划线文字
            'strikethrough'  # 删除线文字
            'color'          # 修改文字颜色
            'ol'             # 有序列表
            'ul'             # 无序列表
            'blockquote'     # 引用
            'code'           # 代码
            'table'          # 表格
            'link'           # 插入链接
            'image'          # 插入图片
            'hr'             # 分割线
            'indent'         # 向右缩进
            'outdent'        # 向左缩进
            'marked'         # Markdown
            'fullscreen'
          ]
          toolbarFloat: false
          pasteImage: true
          maxImageHeight: 2000
          maxImageWidth: 2000
          mention:
            items: STORE.projectMemberList.data
            nameKey: "realname"

        #延时加载
        # require ['simditor-marked', 'simditor-fullscreen'], ->
        simditor = new Simditor options
        simditor.on 'valuechanged', (e, src)->
          content = e.currentTarget.getValue()

          setCache attrs.name, currentUUID, content, true

        cb simditor


      #获取缓存的key
      getCacheKey = (name, uuid)-> "#{name}_#{uuid}"
      #检查是否有缓存的内容
      # getCache = (name, uuid)-> EDITORSTORE.get getCacheKey(name, uuid)
      getCache = (key)-> EDITORSTORE.get key
      #设置缓存
      setCache = (name, uuid, content, auto)-> EDITORSTORE.set getCacheKey(name, uuid), content, auto
      #删除缓存
      removeCache = (name, uuid)-> EDITORSTORE.remove getCacheKey(name, uuid)

      scope.showAlwaysTop = attrs.showAlwaysTop in [true, 'true']

      scope.$on 'editor:content', ($event, name, uuid, content, uploadUrl)->
        #如果有设定name，且当前name和设定的name不一致，则不处理
        return if attrs.name and attrs.name isnt name
        currentUUID = uuid

        #editor可能还没有初始化
        ensureEditor uploadUrl, ()->
          #simditor.setValue content
          #console.log "getCache"
          return if !content
          #simditor.setValue getCache(name, uuid) || content
          simditor.setValue content
          return

      #收到cancel的请求
      scope.$on 'editor:will:cancel', (event, name)->
        #name不一致或者simditor没有初化，都不处理
        return if attrs.name isnt name or not simditor

        #如果是从外部传到的取消请求，则再保存一次数据
        setCache attrs.name, currentUUID, simditor.getValue()
        scope.$emit 'editor:cancel', attrs.name

      scope.onClickCancel = ->
        #用户自主点击取消的，要移除缓存
        # removeCache attrs.name, currentUUID
        simditor.setValue ''
        scope.$emit 'editor:cancel', attrs.name
      scope.onClickSubmit = ->
        #simditor是延时加载的，所以有可能提交按钮已经出现，但simditor没有加载下来的极端情况
        return if not simditor

        data =
          content: simditor.getValue()
          always_top: scope.always_top
        # removeCache attrs.name, currentUUID
        simditor.setValue ''
        scope.$emit 'editor:submit', attrs.name, data


      scope.backList = EDITORSTORE.list()
      scope.onClickChoose = (key)->
        simditor.setValue getCache(key)

      scope.onClickBack = ()->
        key = getCacheKey attrs.name, currentUUID
        simditor.setValue getCache(key)
  ])