'use strict'

define [
  '../ng-module'
  '../utils'
  't!../../views/project/project-all.html'
  't!../../views/project/project-editors.html'
  'v/circles'
], (_module,_utils, _tmplAll, _tmplEditors) ->

  _module.directiveModule
  .directive('projectMenu', ['$rootScope', '$stateParams', 'API', ($rootScope, $stateParams, API)->
    restrict: 'E'
    replace: true
    template: _utils.extractTemplate '#tmpl-project-menu', _tmplAll
    link: (scope, element, attrs)->
      parts = ['project', $stateParams.project_id]
      if $stateParams.version_id
        parts.push 'version'
        parts.push $stateParams.version_id

      scope.baseLink = parts.join('/')

      #获取测试任务的统计
      API.project($stateParams.project_id)
      .issue().stat().test().retrieve().then (result)->
        scope.testStat = result

      scope.onClickInvite = -> $rootScope.$broadcast 'member:invite:show'
  ])

  # .directive('projectHeader', ()->
  #   restrict: 'E'
  #   replace: true
  #   template: _utils.extractTemplate '#tmpl-project-header', _tmplAll
  #   link: (scope, element, attrs)->

  # )

  #项目成员的下拉列表
  .directive('projectMemberDropdown', ()->
    restrict: 'E'
    replace: true
    template: _utils.extractTemplate '#tmpl-project-member-dropdown', _tmplAll
    link: (scope, element, attrs)->
      loaded = false

      #获取到数据后，调用dropdown
      attrs.$observe('items', ->
        #异步获取数据时，items可能还没有赋值，也可能被多次赋值
        return if loaded or not attrs.items
        # loaded = true
        scope.items =_utils.toDyadicArray JSON.parse(attrs.items), 10
      )

      
      # $scope.$emit 'project:member:request', $scope.issue.project_id if !$scope.projectMember or $stateParams.project_id isnt $scope.issue.project_id
  )

  #项目列表
  .directive('projectTiles', ['$location', '$rootScope',
  '$timeout', '$filter', 'API', 'NOTIFY', 'ENUM'
  ($location, $rootScope, $timeout, $filter, API, NOTIFY, ENUM)->
    restrict: 'E'
    replace: true
    scope: {}
    template: _utils.extractTemplate '#tmpl-project-tiles', _tmplAll
    link: (scope, element, attrs)->
      condition = {}
      scope.onClickCreate = ->
        #弹出项目编辑器
        $rootScope.$broadcast 'project:editor:show'

      scope.onClickTile = (event, project)->
        url = "/project/#{project.id}"
        url += "/version/#{project.active_version}" if project.active_version
        url += "/issue"

        url = "/wiki/#{project.id}/issue" if project.flag is ENUM.projectFlag.wiki
        $location.path(url)

      scope.onClickEdit = (event, project)->
        event.stopPropagation()
        $rootScope.$broadcast 'project:editor:show', project.id
        return

      scope.onClickFavorite = (event, project)->
        event.stopPropagation()
        data = type: 'project', target_id: project.id
        method = if project.favorite then 'delete' else 'create'

        API.project(project.id).favorite(data)[method](data).then ()-> searchProject()
        return

      scope.onClickDelete = (event, project)->
        event.stopPropagation()
        return if not confirm('您确定要删除该项目吗？')

        #将项目状态设置为trash
        API.project(project.id).update(status: 'trash').then ->
          $tile = $(event.target).closest('li.tile')
          $tile.fadeOut()
          #通知用户
          NOTIFY.success '该项目已经删除成功'


      scope.$on 'instant-search:change', (event, keyword)->
        return if condition.keyword is keyword

        searchProject keyword: keyword

      #项目被改变的消息
      scope.$on 'project:change', (event)-> searchProject keyword: condition.keyword

      #查询项目
      searchProject = (cond)->
        params =
          pageSize: 9999
          special: true
        condition = _.extend params, cond

        API.project().retrieve(condition).then((result)->
          scope.projects = result
          _.map result.items, (item)->
            item.finished_rate =
              if item.undone_task_total is item.task_total
              then 100
              else 100 - item.undone_task_total / item.task_total * 100

          $timeout (->scope.$emit 'project:tile:loaded'), 0
        )

      searchProject()
  ])

  .directive('projectTileResize', [ ->
    restrict: 'A'
    link: (scope, element, attrs)->
      $element = $(element)

      #重新计算tile的宽度
      caculateTiles = ()->
        $items = $element.find('>li.tile')
        boxWidth = $element.width()
        tileWidth = 250
        margin = 10
        #一行最多显示多少个
        numberOfRow = Math.round(boxWidth / (tileWidth + margin * 2))
        realWidth = (boxWidth - (margin * numberOfRow * 2) - 10) / numberOfRow
        $items.css(width: realWidth)

      $(window).on 'onResizeEx', caculateTiles
      scope.$on 'project:tile:loaded', -> caculateTiles()
      scope.$on '$destroy', -> $(window).off 'onResizeEx', caculateTiles

  ])

  .directive('projectCategoryMenu', ['STORE', ()->
    restrict: 'E'
    replace: true
    template: _utils.extractTemplate '#tmpl-project-menu-category', _tmplAll
    link: (scope, element, attrs)->

  ])  

  .directive('myProjectMenu', ['STORE', ()->
    restrict: 'E'
    replace: true
    template: _utils.extractTemplate '#tmpl-my-project-menu', _tmplAll
    link: (scope, element, attrs)->

  ])  

  
  .directive('myFollowMenu', ['STORE', ()->
    restrict: 'E'
    replace: true
    template: _utils.extractTemplate '#tmpl-my-follow-menu', _tmplAll
    link: (scope, element, attrs)->

  ])  


  .directive('projectCategoryDropdown', ['STORE', ()->
    restrict: 'E'
    replace: true
    template: _utils.extractTemplate '#tmpl-project-category-dropdown', _tmplAll
    link: (scope, element, attrs)->

  ])

  .directive('projectSalvePanel', ['$stateParams', ($stateParams)->
    restrict: 'E'
    replace: true
    template: _utils.extractTemplate '#tmpl-project-salve-panel', _tmplAll
    link: (scope, element, attrs)->
      # showWindowFlag = 1
      _windowChange = (event,showWindow)->
        # 如果有传入窗口
        if showWindow then showWindowFlag = showWindow
        scope.needchange = (document.body.clientWidth < 1280) && window.location.href.indexOf("weekly-report") > -1
        # 宽度够则同时显示list和preview
        if !scope.needchange
          scope.leftViewStyle = {'width':'40%','display':'block'}
          scope.rightViewStyle = {'display':'block'}
          showWindowFlag = 1
          return

        if showWindowFlag is 1
          scope.leftViewStyle = {'width':'100%'}
          scope.rightViewStyle = {'display':'none'}
          showWindowFlag = 2
        else if showWindowFlag is 2
          scope.leftViewStyle = {'display':'none'}
          scope.rightViewStyle = {'width':'100%'}
          showWindowFlag = 1

      scope.windowChange = ()->
        _windowChange(null, null)
      scope.$on "project:window:change", (event, showWindow)-> 
        _windowChange event, showWindow  

      if $stateParams.issue_id
        _windowChange(null,2) 
      else
        _windowChange(null,1)  
  ])

  .directive('projectVersionDropdown', ['STORE', ()->
    restrict: 'E'
    replace: true
    template: _utils.extractTemplate '#tmpl-project-versions-dropdown', _tmplAll
    link: (scope, element, attrs)->
      scope.showMore = attrs.showMore is 'true'
  ])

  .directive('projectMenuHighlight', ['$stateParams', '$location',
  ($stateParams, $location)->
    restrict: 'A'
    link: (scope, element, attrs)->
#      klass = null
#      if $stateParams.myself
#        klass = 'myself'
#      console.log $stateParams
  ])

  .directive('projectMenuBar', ['$rootScope', '$stateParams', ($rootScope, $stateParams)->
    restrict: 'E'
    replace: true
    template: _utils.extractTemplate '#tmpl-project-menu-bar', _tmplAll
    link: (scope, element, attrs)->
      scope.$on 'dropdown:selected', (event, type, value)->
        return if type isnt 'project:menu:manage'
        switch value
          when 'category' then $rootScope.$broadcast 'issue-category:editor:show'
          when 'version' then $rootScope.$broadcast 'project:version:editor:show'
          when 'project' then $rootScope.$broadcast 'project:editor:show', $stateParams.project_id
          when 'webhook' then $rootScope.$broadcast 'project:webhook:editor:show', $stateParams.project_id
  ])

  .directive('projectProcessing', ['$timeout', ($timeout)->
    restrict: 'A'
    replace: true
    link: (scope, element, attrs)->


      $timeout(
        ()->
#          console.log $("##{attrs.domId}").length

          Circles.create
            id: attrs.domId
            radius:     60,
            value:      Math.round(scope.project.finished_rate),
            maxValue:   100,
            width:      6,
            text:       (value)->return value + '%'
            colors:     ['#2d9ab5', '#FFF'],
            duration:   60,
            wrpClass:   'circles-wrp',
            textClass:  'circles-text'
        0
      )

  ])  