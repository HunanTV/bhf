"use strict"
define [
  '../ng-module'
  '../utils'
], (_module, _utils) ->

  _module.controllerModule
  #任务列表
  .controller('issueListController', ['$rootScope', '$scope', '$stateParams', 'API', '$state', '$location',
  ($rootScope, $scope, $stateParams, API, $state, $location)->
    #搜索issue
    searchIssue = (condition)->
      $scope.$parent.$broadcast "project:window:change", 1
      #搜索条件
      cond =
        _.extend {
          tag: $state.params.tag
          category_id: $state.params.category_id
        }, condition

      $scope.condition = cond

      params = getSearchIssueParams(cond)

      #待办中
      issueAPI = API.project($stateParams.project_id).issue()

      issueAPI.retrieve(_.extend({status: 'undone', pageSize: 9999}, params))
      .then (result)-> $scope.undoneIssues = result
      #          scope.$apply()

      $scope.showQuickEditor = Boolean(cond.category_id)
      #加载已经完成
      issueAPI.retrieve(_.extend({status: 'done', pageSize: 10}, params))
      .then (result)-> $scope.doneIssues = result

    getSearchIssueParams = (cond)->
      params = {}

      if cond.keyword #搜索
        $scope.title = "搜索：#{cond.keyword}"
        params.keyword = cond.keyword
      else if $stateParams.myself
        #获取用户自己的任务
        $scope.title = "我相关的任务"
        $scope.title = $location.$$search.title if $location.$$search.title
        params.myself = true

      else if $stateParams.follow
        $scope.title = "我相关注"
        $scope.title = $location.$$search.title if $location.$$search.title
        params.follow = true

      else if cond.category_id
        $scope.title = $location.$$search.title
      else
        $scope.title = "所有任务"


      #指定分类id
      params.category_id = $state.params.category_id
      #指定版本
      params.version_id = $state.params.version_id

      return params

    $rootScope.$on 'pagination:change',(event, page, uuid, cb)->
      return if uuid isnt 'done_issues'
      #搜索条件
      params = getSearchIssueParams($scope.condition)
      
      issueAPI = API.project($stateParams.project_id).issue()
      
      issueAPI.retrieve(_.extend({status: 'done', pageSize: 10, pageIndex: page}, params))
      .then (result)-> 
        $scope.doneIssues = result



#      scope.$apply()
#      issueAPI.retrieve(_.extend({status: 'testing', pageSize: 9999}, params))
#      .then (result)-> $scope.testingIssues = result

    #强制重新加载数据
    $scope.$on 'issue:list:reload', (event)-> searchIssue()
    #某个issue被修改
    $scope.$on 'issue:change', ()-> searchIssue()

    $scope.$on 'instant-search:change', (event, keyword)->
      return if $scope.condition.keyword is keyword
      searchIssue keyword: keyword

    #更改状态
    $scope.$on 'issue:status:change', (event, issue_id, oldStatus, newStatus)->
      return if oldStatus is newStatus
      API.project($stateParams.project_id).issue(issue_id)
      .update(status: newStatus).then ()-> searchIssue()

    # $rootScope.$on 'project:loaded', (event,result)->
    #   $scope.project = result
    searchIssue()
  ])

  #测试任务列表
  .controller('testListController', ['$scope', '$stateParams', 'API', '$state', '$location',
  ($scope, $stateParams, API, $state, $location)->
    $scope.condition = {}
    issueAPI = API.project($stateParams.project_id).issue()

    searchIssue = (condition)->
      params = _.extend tag: 'test', condition
      #测试中
      issueAPI.retrieve(_.extend(status: ['doing', 'repaired', 'pause'], params)).then (result)->
        $scope.doing = result

      #修复中
      issueAPI.retrieve(_.extend(status: 'repairing', params)).then (result)->
        $scope.repairing = result

      #获取测试已审的
      issueAPI.retrieve(_.extend(status: 'reviewing', params)).then (result)->
        $scope.reviewing = result

      #已完成
      issueAPI.retrieve(_.extend(status: 'done', params)).then (result)->
        $scope.done = result

#    实时搜索
    $scope.$on 'instant-search:change', (event, keyword)->
      return if $scope.condition.keyword is keyword
      $scope.condition.keyword = keyword
      searchIssue keyword: keyword

    $scope.$on 'issue:status:change', (event, issue_id, oldStatus, newStatus)->
      return if oldStatus is newStatus
      API.project($stateParams.project_id).issue(issue_id)
      .update(status: newStatus).then ()-> searchIssue()

    searchIssue()
  ])