define [
  '../ng-module'
  'utils'
  't!../../views/commit/commit-all.html'
], (_module, _utils, _template)->

  _module.directiveModule
  .directive('commitIssueList', ['$stateParams', 'API', ($stateParams, API)->
    restrict: 'E'
    replace: true
    scope: false
    template: _utils.extractTemplate '#tmpl-commit-issue-list', _template
    link: (scope, element, attrs)->
      loadCommitList = ->
        API.project($stateParams.project_id).issue($stateParams.issue_id)
        .commit().retrieve(pageSize: 9999).then (result)->
          scope.commits = result.items

      loadCommitList()
  ])
  .directive('commitImportModal', ['$stateParams', 'API', 'NOTIFY', 'LOADING', ($stateParams, API, NOTIFY, LOADING)->
      restrict: 'E'
      replace: true
      scope: false
      template: _utils.extractTemplate '#tmpl-commit-import', _template
      link: (scope, element,  attrs)->

        project_id = $stateParams.project_id

        $element = $(element)

        scope.$on("commit:import:modal:show", ->
          loadGitlabProjects(()-> $element.modal(showClose: false))
        )

        loadGitlabProjects = (cb)->
          API.project(project_id).ownedGits().retrieve().then((gits)->
            scope.git_project = gits[0]
            scope.gits = gits
            scope.git_project_branch = gits[0].branches[0]
            cb and cb()
          )

        scope.gitChanges = ->
          scope.git_project_branch = scope.git_project.branches[0]

        scope.onClickSave = ->
          LOADING.loading()
          limit = parseInt(scope.limit) or 0 #取整，否则置０，让服务器选择默认值
          params =
            project_id: project_id
            git_project_id: scope.git_project.id
            git_project_branch: scope.git_project_branch
            limit: limit

          API.commit().import().retrieve(params).then(->
            LOADING.loaded()
            NOTIFY.success("导入完成，如未显示请刷新页面")
            $.modal.close()
            scope.$emit("commit:refresh:ready")
          )

        scope.onClickCancel = ->
          $.modal.close()
          return false
    ])