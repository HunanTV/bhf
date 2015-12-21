###
  Author: ec.huyinghuan@gmail.com
  Date: 2015.07.09 15:30 PM
  Describe:
    创建gitlab 新仓库并关联到项目
###

define [
  '../ng-module'
], (_module)->

  template = "
    <div class='gitlab-create-form'>
      <header>
        <h3><i class='icon small create title'></i>创建新的仓库</h3>
      </header>
      <input type='text'
        placeholder='字母,数字,_ 的组合'
        ng-model='gitlab_name'
      >
      <button ng-click='save()' class='primary default btn_import'>创建</button>
    </div>
  "

  _module.directiveModule
  .directive('gitlabCreateForProject', ['$stateParams', 'NOTIFY', ($stateParams, NOTIFY)->
    restrict: 'E'
    replace: true
    scope: bean: '=', name: "@"
    template: template
    link: (scope, element, attrs)->
      reg = /^\w+$/
      scope.save = ->
        return NOTIFY.warn("仓库名不能为空") if not scope.gitlab_name
        return NOTIFY.warn("只能是字母，数字和下划线组成") if not reg.test(scope.gitlab_name)
        scope.bean.doAction('create', scope.gitlab_name)

      scope.$on("component:#{scope.name}:reset", ->
        scope.gitlab_name = ""
      )


  ])