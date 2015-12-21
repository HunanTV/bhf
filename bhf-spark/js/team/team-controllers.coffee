"use strict"
#合集的controller，如果某个controller很大，则独立出去
define [
  '../ng-module'
  'moment'
  '_'
  '../utils'
], (_module, _moment, _, _utils) ->
  _module.controllerModule.
  controller('teamController', ['$rootScope', '$scope',
  '$routeParams', '$location', '$stateParams', 'API', 'STORE', 'NOTIFY',
  ($rootScope, $scope, $routeParams, $location, $stateParams, API, STORE, NOTIFY)->
    teamAPI = API.team($stateParams.team_id)
    $scope.team_id = $stateParams.team_id
    $scope.title = $location.$$search.title

    #更新项目成员
    updateTeamMember = ->
      teamAPI.member().retrieve().then (result)->
        $scope.teamMember = result.members
        $scope.teamRole = result.role
        STORE.teamMemberList.data = result

    #更新所在的所有团队
    updateTeamCategory = ->
      API.team().retrieve().then (result)->
        $scope.team = getTeamAndInvitation result
        STORE.teamCategory.data = result

    getTeamAndInvitation = (teams)->
      teamObj = 
        teamCategory: []
        inviteCategory: []
      type = ["inviteCategory", "teamCategory"]
      teamObj[type[team.status]].push(team) for team in teams 
      teamObj
    
    projectVersionSelected = (value)->

      return alert('新建版本的功能暂未发') if value is '-1'

      url = "/team/#{$stateParams.team_id}"

      $scope.$apply -> $location.path url


    removeTeam = ()->
      teamAPI.delete().then (result)->
        NOTIFY.success '删除成功！'
        window.location.href = "/team/0/list"


    $scope.createTeam = ()->
      $scope.$broadcast 'team:setting:show'
    $scope.editTeam = ()->
      $scope.$broadcast 'team:setting:show', $scope.title, $scope.team_id
        

    #更新成员列表信息
    $scope.$on "team:remove", -> removeTeam()
    $scope.$on "team:member:request", -> updateTeamMember()
    $scope.$on "team:category:request", -> updateTeamCategory()

    #展示创建成员窗口
    $scope.$on("member:creator:toshow", (event,data)->
      $scope.$broadcast("member:creator:show",data)
    )

    $scope.$on 'dropdown:selected', (event, type, value)->
      switch type
        when 'project:version' then projectVersionSelected value



    updateTeamMember() if parseInt($stateParams.team_id) > 0
    updateTeamCategory()
    # updateProject()
    # updateProjectVersion()
  ])
