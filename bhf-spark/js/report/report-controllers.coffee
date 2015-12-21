"use strict"
#合集的controller，如果某个controller很大，则独立出去
define [
  '../ng-module'
  'moment'
  '_'
  '../utils'
], (_module, _moment, _, _utils) ->

  _module.controllerModule
  #报表页面
  .controller('reportController', ['$scope', 'API'
    ($scope, API)->
      $scope.title = "我的报表"
      #获取身份为leader的团队
      updateTeamCategory = ->
        API.team().retrieve({role:'l'}).then (result)->
          $scope.teamCategory = result

      updateTeamCategory()
  ])
  #项目周报的列表
  .controller('weeklyReportListController', ['$scope', '$stateParams', '$location', 'API', 'WEEKLIST',
    ($scope, $stateParams, $location, API, WEEKLIST)->
      $scope.weeks = WEEKLIST(30)
      $scope.title = "项目周报"
      $scope.title = "【#{$location.$$search.title}】团队周报" if $stateParams.team_id 
      $scope.title = "我的周报" if parseInt($stateParams.team_id) is 0
      $scope.teamName = $location.$$search.title

      $scope.createReport = ()->
        $scope.$broadcast "report:create:show"


  ])

  #项目周报的详细
  .controller('reportWeeklyDetailsController', ['$rootScope', '$scope', '$stateParams', '$location', 'API',
    ($rootScope, $scope, $stateParams, $location, API)->
      start_time = $stateParams.start_time || $location.$$search.start_time
      end_time = $stateParams.end_time || $location.$$search.end_time
      project_id = $stateParams.project_id || $location.$$search.project_id || null
      team_id = $stateParams.team_id || $location.$$search.team_id || null

      $scope.printExtraUrl = ""
      $scope.printExtraUrl += "&team_id=#{team_id}" if team_id
      $scope.printExtraUrl += "&project_id=#{project_id}" if project_id

      cond =
        start_time: start_time
        end_time: end_time
        project_id: project_id

      _.extend $scope, cond

      API.report(team_id).weekly().retrieve(cond).then (result)->
        $scope.report = result
  ])