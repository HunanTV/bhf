define [
  '../ng-module'
  '../utils'
  '_'
], (_module,_utils, _) ->

  _module.directiveModule
  .directive('issueDetails', ['$rootScope', '$stateParams', '$location', '$http', '$timeout', 'API', 'NOTIFY',
  ($rootScope, $stateParams, $location, $http , $timeout, API, NOTIFY)->
    restrict: 'A'
    replace: true
    link: (scope, element, attr)->
      editorKey = 'issue'
      issueAPI = null

      scope.notFound = false
      scope.editing = false
      scope.assetPreviewer = show: false
      scope.showAlwaysTop = true

      #提交评论
      submitComment = (data)->
        issueAPI.comment().create(content: data.content).then (result)->
          NOTIFY.success('评论保存成功')
          #刷新评论数据
          scope.$broadcast 'comment:list:reload'

      scope.onClickStatus = (event, issue)->
        scope.$emit 'issue:status-dropdown:show', event, issue
        return

      #关闭asset的预览
      scope.onClickCloseAssetPreviewer = ->
        scope.assetPreviewer.show = false

      #阻止此区域的事件冒泡，
      scope.onClickIssue = (event)->
        event.stopPropagation() if scope.editing
        return

      scope.$watch 'issue', ->
        return if not scope.issue
        issueAPI = API.project(scope.issue.project_id).issue(scope.issue.id)
        scope.uploadUrl = "/api/project/#{scope.issue.project_id}/attachment"

        #是否主动打开编辑器
        if $location.$$search.editing is 'true' then scope.onClickEdit()

      #预览压缩包
      scope.$on 'asset:bundle:preview', (event, asset_id, bundleName)->
        scope.assetPreviewer.show = true
        scope.assetPreviewer.bundleName = bundleName

        #取得素材详细内容才触发事件
        issueAPI.assets(asset_id).retrieve().then (result)->
          scope.$broadcast 'asset:bundle:load', result



      # scope.$on 'asset:create:issues', (event, asset_id)->
      #   url = "/api/project/#{scope.issue.project_id}/asset/#{asset_id}/split"
      #   params = version_id: $stateParams.version_id, category_id: $stateParams.category_id
      #   $http.post(url, params).success (body)->
      #     $rootScope.$broadcast 'issue:list:reload'

      scope.$on 'dropdown:selected', (event, type, value)->
        field = null
        switch type
          when 'issue:owner'
            field = 'owner' if ~~value isnt scope.issue.owner
          when 'issue:priority'
            field = 'priority' if ~~value isnt scope.issue.priority
          when 'issue:category'
            field = 'category_id' if ~~value isnt scope.issue.category_id
          when 'issue:version'
            field = 'version_id' if ~~value isnt scope.issue.version_id
#          when 'issue:status'
#            field = 'status' if ~~value isnt scope.issue.status

        return if not field
        data = {}
        data[field] = value
        issueAPI.update(data).then ->
          scope.issue[field] = value
          $rootScope.$broadcast 'issue:list:reload'


      #更改状态
      scope.$on 'issue:status:change', (event, issue_id, oldStatus, newStatus, split)->
        return if oldStatus is newStatus
        _issueAPI = issueAPI
        _issueAPI = API.project(scope.issue.project_id).issue(scope.issue.id).split(issue_id) if split

        _issueAPI.update(status: newStatus).then ()->
          # scope.issue.status = newStatus if !split
          $rootScope.$broadcast 'issue:list:reload'
          $rootScope.$broadcast 'issue:detail:reload'


      #保存修改时间
      scope.$on 'datetime:change', (event, name, date)->
        switch name
            when 'plan_finish_time'
              issueAPI.update(plan_finish_time:date).then (result)->
                 if(result) then scope.issue.plan_finish_time = date


      scope.onClickSplit = ()->
        scope.splitShow = true
        $timeout (-> $("#split-text").focus()), 100
        if !scope.issue.splited
          issueAPI.update(splited:1).then (result)->
            scope.splitShow = true
            $rootScope.$broadcast 'issue:detail:reload' if result


      scope.onClickDelete = ()->
        return if not confirm('您确定要删除这条记录吗')
        issueAPI.update(status : 'trash').then ()->
          NOTIFY.success '删除成功'

          #切换url
          url = $location.$$path.replace(/(.+)\/\d+$/, '$1')
          $location.path(url)
          $rootScope.$broadcast 'issue:change'

      scope.onClickEdit = ()->
        scope.splitShow = false
        # console.log scope.issue.tag
        # 当类型为表单时弹出表单窗口，其他的则显示富文本编辑器
        if scope.issue.tag isnt 'form'
        #延时让页面先显示出来，然后初始化editor(仅在第一次初始化)，避免editor获取不到宽度
          scope.editing = true
          window.setTimeout(->
            scope.$broadcast 'editor:content', editorKey, scope.issue.id, scope.issue.content, scope.uploadUrl
          , 1)
          $('body').one 'click', -> scope.$broadcast 'editor:will:cancel', editorKey
        else 
          $rootScope.$broadcast 'issue:form:show', scope.issue.id, JSON.parse(scope.issue.content).uuid
        return

      scope.$on 'editor:submit', (event, name, data)->
        #提交评论
        return submitComment(data) if name is 'comment'

        scope.editing = false
        scope.issue.content = data.content

        #保存到数据库
        newData = _.pick(scope.issue, ['content', 'title'])
        issueAPI.update(newData).then((result)->
          NOTIFY.success('更新成功')
          $timeout(hljs.initHighlighting,100)
          $rootScope.$broadcast 'issue:list:reload'
        )

      scope.$on 'editor:cancel', (event, name)->
        return if editorKey isnt name
        scope.editing = false
        scope.$apply() if not scope.$$phase

      #强行显示issue的编辑器
      scope.$on 'issue:editor:show', ()-> scope.onClickEdit()


      scope.followIssue = ()->
        issueAPI.follow().create().then (res)->
          

  ])