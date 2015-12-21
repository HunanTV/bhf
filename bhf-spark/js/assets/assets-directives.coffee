define [
  '../ng-module'
  '../utils'
  '_'
  'marked'
  't!../../views/assets/assets-all.html'
  'pkg/colorbox/jquery.colorbox'
], (_module, _utils, _, _marked, _template) ->

  _module.directiveModule
  #上传素材
  .directive('uploadAssets', ['$stateParams', 'API', 'NOTIFY', ($stateParams, API, NOTIFY)->
    restrict: 'A'
    replace: true
    link: (scope, element, attr)->
      $progress = $(element).find '.progress'
      $percent = $(element).find '.percent'
      $mask = $(element).find '.mask'

      filterFn = (file, info)->
        confirmSize = Math.pow(2, 28)
        maxSize = Math.pow(2, 30)
        #超过256M则提示
        if file.size > confirmSize
          return confirm('上传大文件浏览器可能会出现卡死的情况，你确定要上传么')
        else if file.size > maxSize
          alert("上传文件不能超过#{maxSize / 1024 / 1024}M")
          return false

        return true

      resetProgress = ()->
        $progress.text('0%')
        $percent.css('width', '0')
        $mask.hide()

      #上传的回调
      uploadFn = (files, rejected)->
        if files.length is 0
          NOTIFY.warn '无可上传的文件'
          return

        $mask.show()
        FileAPI.upload
          url: "/api/project/#{$stateParams.project_id}/issue/#{$stateParams.issue_id}/assets"
          files: assets: files
          #完成后的操作
          complete: (err, xhr)->
            resetProgress()
            scope.$emit "assets:upload:finish"
            return NOTIFY.error '文件上传失败' if err

            NOTIFY.success '所有文件已经上传成功啦'

          #进度
          progress: (event, file, xhr, options)->
            percent = (event.loaded / event.total * 100)
#            console.log percent
            $progress.text percent.toFixed(2) + '%'
            $percent.css('width', percent + '%')

      #延时加载上传文件
      require ['v/FileAPI.html5'], ->
        target = element[0]
        FileAPI.event.on target, 'change', (event)->
          files = FileAPI.getFiles(event)
          FileAPI.filterFiles files, filterFn, uploadFn
  ])

  #素材的缩略图列表
  .directive('assetThumbnails', ['$stateParams', 'API', ($stateParams, API)->
    restrict: 'E'
    replace: true
    template: _utils.extractTemplate '#tmpl-asset-thumbnails', _template
    link: (scope, element, attr)->
      assetAPI = API.project($stateParams.project_id).issue($stateParams.issue_id)

      #获得附件列表
      getAssetList = ()->
        assetAPI.assets().retrieve(pageSize: 10).then (result)->
          scope.assets = result

      #删除素材
      scope.onClickRemove = (event, asset)->
        return if not confirm('您确定要删除这个素材吗？')
        assetAPI.assets(asset.id).delete().then -> getAssetList()

      scope.onClickPreviewPicture = (event, asset)->
        $(event.target).colorbox(maxWidth: 1024, photo: true)
        event.preventDefault()
        return false

      scope.onClickPreviewBundle = (event, asset)->
        scope.$emit 'asset:bundle:preview', asset.id, asset.original_name

      # scope.onClickCreateIssues = (event, asset)->
      #   scope.$emit 'asset:create:issues', asset.id

      #监听事件 assets:list:update
      scope.$on "assets:list:update", ()-> getAssetList()

      #初次进入直接拉取一次数据
      getAssetList()
  ])

  .directive('assetUnwindPreviewer', ['$sce', '$state', ($sce, $state)->
    restrict: 'E'
    replace: true
    template: _utils.extractTemplate '#tmpl-asset-unwind-previewer', _template
    link: (scope, element, attrs)->

  ])

  #预览素材文件
  .directive('assetFilePreviewer', ['$stateParams', '$http', 'API', ($stateParams, $http, API)->
    restrict: 'E'
    replace: true
    template: _utils.extractTemplate '#tmpl-asset-file-previewer', _template
    link: (scope, element, attrs)->

      #格式化markdown
      formatMarkdown = (content)->
        scope.markdownContent = _marked(content)

      formatCode = (content)->
        #延时加载h
        require ['highlight'], ->
          obj = $(element).find('code')
          obj.text content
          hljs.highlightBlock obj[0]

      loadAsset = ()->
#        API.project($stateParams.project_id).assets($stateParams.asset_id).file().
        url = "/api/project/#{$stateParams.project_id}/asset/#{$stateParams.asset_id}/read"
        scope.assetUrl = url

        return if scope.assetType is 'image'

        $http.get(url).success (body)->
          switch scope.assetType
            when 'markdown' then formatMarkdown body
            when 'code' then formatCode body

      scope.$watch 'assetType', ->
        loadAsset() if scope.assetType
  ])

  #素材预览的头部
  .directive('assetPreviewerHeader', [()->
    restrict: 'E'
    replace: true
    template: _utils.extractTemplate '#tmpl-asset-previewer-header', _template
    link: (scope, element, attrs)->

  ])

  .directive('assetBundleUnwind', ['$stateParams', '$filter', 'API', ($stateParams, $filter, API)->
    restrict: 'E'
    replace: true
    scope: {}
    template: _utils.extractTemplate '#tmpl-assets-unwind', _template
    link: (scope, element, attrs)->
      scope.bundleName = ''
      scope.subdir = []

      scope.onClickNav = (event, index)->
        scope.subdir = scope.subdir.slice(0, index + 1)
        loadBundle()

      scope.onClickAsset = (event, asset)->
        #文件夹
        if asset.is_dir
          scope.subdir.push asset.original_name
          loadBundle()
          return

        #预览文件或者下载文件
#        subdir = _.clone(scope.subdir)
#        subdir.push(asset.original_name)

      scope.$on 'asset:bundle:load', (event, asset)->
        scope.asset = asset
        scope.unwind = []
        loadBundle()

      loadBundle = ()->
        params =
          subdir: scope.subdir.join('/')

        API.project($stateParams.project_id).assets(scope.asset.id)
        .unwind().retrieve(params).then (result)->
          _.map result, (item)->
            return if item.is_dir
            dig = "?dig=#{scope.subdir.join('/')}/#{item.original_name}"
            item.url = $filter('assetLink')(scope.asset, false) + dig

#            item.url = [
#              '/api/project/'
#              project_id
#              '/asset/'
#              scope.asset_id
#              '/read'
#              '?download=true&dig='
#              scope.subdir.join('/')
#              '/'
#              item.original_name].join('')

          scope.unwind = result
  ])