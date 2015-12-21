'use strict'

define [
  '../ng-module'
  '../utils'
  't!../../views/project/project-editors.html'
], (_module, _utils, _tmplEditors) ->

  _module.directiveModule
  #项目编辑器
  .directive('projectEditor', ['$rootScope', '$location', 'API', 'NOTIFY',
    ($rootScope, $location, API, NOTIFY)->
      restrict: 'E'
      replace: true
      scope: {}
      template: _utils.extractTemplate '#tmpl-project-editor', _tmplEditors
      link: (scope, element, attrs)->
        $element = $(element)

        #加载项目信息
        loadProject = (project_id)->
          params = get_role: true
          API.project(project_id).retrieve(params)


        scope.onClickDelete = (event, project_id)->
          return if not confirm('您确定将要删除这个项目吗？')
          API.project(project_id).update(status: 'trash').then ->
            $.modal.close()
            NOTIFY.success('删除成功，刷新项目列表（功能未开发）')

        scope.onClickSave = ->
          return NOTIFY.error('项目名称必需输入') if not scope.data.title
          method = if scope.data.id then 'update' else 'create'

          API.project(scope.data.id)[method](scope.data).then (result)->
            NOTIFY.success '项目信息保存成功'
            $.modal.close()
            #通知项目被改变
            $rootScope.$broadcast 'project:change', method, scope.data.id || result.id

        scope.onClickCancel = ->
          $.modal.close()
          return false

        scope.$on "project:editor:show", (event, project_id)->
          #初始化项目数据
          scope.editor_title = '新建'
          scope.contextName = 'project'
          scope.data =
            status: 'active'
          #新建项目，直接显示弹窗
          if not project_id
            return $element.modal(showClose: false)

          #加载项目资料
          loadProject(project_id).then (result)->
            #检查权限，用户必需是leader或者root才能编辑项目
            return NOTIFY.error('您没有权限修改此项目') if result.role isnt 'l'

            scope.editor_title = '编辑'
            scope.data =
              id: result.id
              title: result.title
              description: result.description
              status: result.status

            $element.modal(showClose: false)

        scope.$on 'project:editor:hide', -> $model.close()
  ])

  #issue分类的编辑器
  .directive('issueCategoryEditor', ['$stateParams', '$location', 'API', 'NOTIFY',
    ($stateParams, $location, API, NOTIFY)->
      restrict: 'E'
      replace: true
      scope: {}
      template: _utils.extractTemplate '#tmpl-issue-category-editor', _tmplEditors
      link: (scope, element, attrs)->
        scope.editModel = {}
        projectAPI = API.project($stateParams.project_id)

        $element = $(element)
        loadIssueCategory = (cb)->
          projectAPI.category().retrieve().then (result)->
            scope.category = result
            cb?()

        scope.onClickSave = ()->
          if not scope.editModel.title
            NOTIFY.warn('分类名称必需输入')
            return

          short_title = scope.editModel.short_title
          if short_title and not /^[\w\d_]+$/i.test(short_title)
            NOTIFY.warn('别名只能是英文数字和下划线')
            return

          method = if scope.editModel.id then 'update' else 'create'
          projectAPI.category(scope.editModel.id)[method](scope.editModel).then ->
            NOTIFY.success '分类保存成功'
            #更新数据
            loadIssueCategory()
            #清除数据
            scope.editModel = {}

        #删除
        scope.onClickDelete = (event, data)->
          return if not confirm('您确定要删除这个分类么？')
          projectAPI.category(data.id).delete().then ->
            NOTIFY.success '删除分类成功'
            loadIssueCategory()
            #如果这条数据正在编辑，则清空
            scope.editModel = {} if scope.editModel.id is data.id

        scope.onClickEdit = (event, data)->
          scope.editModel = _.pick data, 'id', 'title', 'short_title'
          return

        scope.onClickCancel = ()->
          $.modal.close()
          return

        scope.$on 'issue-category:editor:show', (event)->
          #收到数据再显示弹窗
          loadIssueCategory -> $element.modal showClose: false

        scope.$on 'issue-category:editor.hide', -> $.modal.close()
  ])

  #版本的管理
  .directive('projectVersionEditor', ['$stateParams', '$location', 'API', 'NOTIFY',
    ($stateParams, $location, API, NOTIFY)->
      restrict: 'E'
      replace: true
      scope: {}
      template: _utils.extractTemplate '#tmpl-project-version-editor', _tmplEditors
      link: (scope, element, attrs)->
        scope.editModel = {}
        projectAPI = API.project($stateParams.project_id)

        $element = $(element)
        loadProjectVersion = (cb)->
          projectAPI.version().retrieve().then (result)->
            scope.version = result
            cb?()

        scope.onClickSave = ()->
          if not scope.editModel.title
            NOTIFY.warn('版本名称必需输入')
            return

          short_title = scope.editModel.short_title
          if short_title and not /^[\w\d_]+$/i.test(short_title)
            NOTIFY.warn('别名只能是英文数字和下划线')
            return

          method = if scope.editModel.id then 'update' else 'create'
          projectAPI.version(scope.editModel.id)[method](scope.editModel).then ->
            NOTIFY.success '版本保存成功'
            #更新数据
            loadProjectVersion()
            #清除数据
            scope.editModel = {}

        #修改状态
        scope.onChangeStatus = (event, data, status)->
          projectAPI.version(data.id).update(status: status).then ->
          NOTIFY.success '状态修改成功'
          loadProjectVersion()

        #删除
        scope.onClickDelete = (event, data)->
          return if not confirm('您确定要删除这个版本么？')
          projectAPI.version(data.id).delete().then ->
            NOTIFY.success '删除版本成功'
            loadProjectVersion()
            #如果这条数据正在编辑，则清空
            scope.editModel = {} if scope.editModel.id is data.id

        scope.onClickEdit = (event, data)->
          scope.editModel = _.pick data, 'id', 'title', 'short_title', 'status'
          return

        scope.onClickCancel = ()->
          $.modal.close()
          return

        scope.$on 'project:version:editor:show', (event)->
          #收到数据再显示弹窗
          loadProjectVersion -> $element.modal showClose: false

        scope.$on 'project:version:editor.hide', -> $.modal.close()
  ])

  #webhook的管理
  .directive('projectWebhookEditor', ['$stateParams', '$location', 'API', 'NOTIFY',
    ($stateParams, $location, API, NOTIFY)->
      restrict: 'E'
      replace: true
      scope: {}
      template: _utils.extractTemplate '#tmpl-project-webhook-editor', _tmplEditors
      link: (scope, element, attrs)->
        scope.editModel = {trigger:'issue'}
        projectAPI = API.project($stateParams.project_id)

        $element = $(element)
        loadProjectWebhook = (cb)->
          projectAPI.webhook().retrieve().then (result)->
            scope.webhook = result
            cb?()

        scope.onClickSave = ()->
          return NOTIFY.warn('必须输入URL') if !scope.editModel.url

          method = if scope.editModel.id then 'update' else 'create'

          projectAPI.webhook(scope.editModel.id)[method](scope.editModel).then ->
            NOTIFY.success '保存成功'
            #更新数据
            loadProjectWebhook()
            #清除数据
            scope.editModel = {trigger:'issue'}


        scope.onClickEdit = (event, data)->
          scope.editModel = _.pick data, 'id', 'trigger', 'url'

        scope.onClickDelete = (event, data)->
          return if not confirm('您确定要删除么？')
          projectAPI.webhook(data.id).delete().then ->
            NOTIFY.success '删除成功'
            loadProjectWebhook()
            #如果这条数据正在编辑，则清空
            scope.editModel = {} if scope.editModel.id is data.id

        scope.onClickCancel = ()->
          $.modal.close()
          return



        scope.$on 'project:webhook:editor:show', (event)->
          #收到数据再显示弹窗
          loadProjectWebhook -> $element.modal showClose: false




  ])
