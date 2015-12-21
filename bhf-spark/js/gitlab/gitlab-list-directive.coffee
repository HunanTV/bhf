###
  Author: ec.huyinghuan@gmail.com
  Date: 2015.07.06
  Describe:
    Gitlab仓库的delete, fork, 和 commit的同步
###
define [
  '../ng-module'
], (_module)->

  templateList = "
    <div class='gitlab-list'>
      <header>
        <h3><i class='icon small list title'></i>Git仓库列表</h3>
      </header>
      <ul>
        <li ng-repeat='item in gitList' title='{{item.git}}'>
          {{onlyShowName(item.git)}} <gitlab-action-bar item='item' bean='bean'></gitlab-action-bar>
        </li>
      </ul>
    </div>
  "

  templateActionBar = "
    <div class='action-bar'>
      <a ng-click='del()'><i class='icon small del action'></i>删除</a>
      <a ng-click='fork()'><i class='icon small fork action'></i>Fork</a>
    </div>
  "

  _module.directiveModule
    .directive('gitlabList', ['$stateParams', ($stateParams)->
      restrict: 'E'
      replace: true
      scope: bean: "=",  name: "@"
      template: templateList
      link: (scope, element, attrs)->

        scope.onlyShowName = (gitUrl)->
          gitUrl = gitUrl or ""
          gitUrl.split(":")[1]

        loadData = ->
          scope.bean.getData(scope.name).then((data)->
            scope.gitList = data
          )

        #刷新事件监听
        scope.$on("component:#{scope.name}:reload", ->
          loadData()
        )

        #初始化
        loadData()

    ])
    .directive('gitlabActionBar', [->
      restrict: 'E'
      replace: true
      scope: item: "=", bean: "="
      template: templateActionBar
      link: (scope, element, attrs)->
        scope.fork = ->
          scope.bean.doAction("fork", scope.item.git_id)
        scope.del = ->
          scope.bean.doAction("del", scope.item.id)
    ])