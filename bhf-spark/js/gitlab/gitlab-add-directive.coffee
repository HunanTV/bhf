###
  Author: ec.huyinghuan@gmail.com
  Date: 2015.07.07 15:30 PM
  Describe:
    添加已有仓库关联到项目
###

define [
  '../ng-module'
], (_module)->

  template = "
    <div class='gitlab-add-form'>
      <header>
        <h3><i class='icon small add title'></i>添加已有仓库</h3>
      </header>
      <p>如果你的gitlab中已经存在与此项目关联的，请在此处添加 <a href='' >如何知道我的Git仓库地址?</a></p>

      <input type='text'
        placeholder='git@git.hunantv.com:honey-lab/bhf.git'
        ng-model='gitlab_url'
      >
      <button ng-click='save()'  class='primary default btn_import'>添加</button>

    </div>
  "

  _module.directiveModule
  .directive('gitlabAddToProject', ['$stateParams', 'NOTIFY', ($stateParams, NOTIFY)->
    restrict: 'E'
    replace: true
    scope: bean: '=', name: "@"
    template: template
    link: (scope, element, attrs)->

      reg = /^git@git\.hunantv\.com:.+\/.+\.git$/

      scope.save = ->
        return NOTIFY.warn("gitlab地址不能为空") if not scope.gitlab_url
        return NOTIFY.warn("gitlab地址格式不正确") if not reg.test(scope.gitlab_url)
        scope.bean.doAction('add', scope.gitlab_url)

      scope.$on("component:#{scope.name}:reset", ->
        scope.gitlab_url = ""
      )


  ])