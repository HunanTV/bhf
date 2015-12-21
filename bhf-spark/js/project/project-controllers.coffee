"use strict"
#合集的controller，如果某个controller很大，则独立出去
define [
  '../ng-module'
  'moment'
  '_'
  '../utils'
], (_module, _moment, _, _utils) ->
  _module.controllerModule.
  controller('projectController', ['$rootScope', '$scope',
  '$routeParams', '$location', '$stateParams', 'API', 'STORE',
  ($rootScope, $scope, $routeParams, $location, $stateParams, API, STORE)->
    projectAPI = API.project($stateParams.project_id)

    #更新项目信息
    updateProject = ->
      #获取项目的信息
      projectAPI.retrieve().then((result)->
        $scope.project = result
        $rootScope.$broadcast 'project:loaded', result
      )

    #更新项目成员
    updateProjectMember = ->
      projectAPI.member().retrieve().then (result)->
        $scope.projectMember = result
        STORE.projectMemberList.data = result

    #更新issue的分类
    updateProjectCategory = ->
      projectAPI.category().retrieve().then (result)->
        $scope.projectCategory = result
        STORE.projectCategory.data = result

    #获取版本信息
    updateProjectVersion = ->
      projectAPI.version().retrieve(status: 'available').then (result)->
        $scope.projectVersion = result
        STORE.projectVersion.data = result
        $rootScope.$broadcast 'project:version:loaded', result

    #项目版本被选中
    projectVersionSelected = (value)->

      return alert('新建版本的功能暂未发') if value is '-1'

      url = "/project/#{$stateParams.project_id}"
      url += "/version/#{value}" if value isnt 'all'
      url += "/issue"
      $scope.$apply -> $location.path url

    $scope.user = STORE.user.data
    #更新成员列表信息
    $scope.$on "project:member:request", -> updateProjectMember()
    $scope.$on "project:category:request", -> updateProjectCategory()

    #展示创建成员窗口
    $scope.$on("member:creator:toshow", (event,data)->
      $scope.$broadcast("member:creator:show",data)
    )

    $scope.$on 'dropdown:selected', (event, type, value)->
      switch type
        when 'project:version' then projectVersionSelected value
    

    updateProjectMember()
    updateProjectCategory()
    updateProject()
    updateProjectVersion()
  ])
  .controller('myProjectController', ['$rootScope', '$scope', '$routeParams', '$location', '$stateParams', 'API', 'STORE',
  ($rootScope, $scope, $routeParams, $location, $stateParams, API, STORE)->
 #查询项目

    $scope.myproject = true;
    $scope.title = "个人中心";

    #更新项目成员
    updateProjectMember = (project_id)->
      project_id = $stateParams.project_id if !project_id
      API.project(project_id).member().retrieve().then (result)->
        $scope.projectMember = result
        STORE.projectMemberList.data = result

    #更新issue的分类
    updateProjectCategory = (project_id)->
      project_id = $stateParams.project_id if !project_id
      API.project(project_id).category().retrieve().then (result)->
        $scope.projectCategory = result
        STORE.projectCategory.data = result

    #获取版本信息
    updateProjectVersion = (project_id)->
      project_id = $stateParams.project_id if !project_id
      API.project(project_id).version().retrieve(status: 'available').then (result)->
        $scope.projectVersion = result
        STORE.projectVersion.data = result
        $rootScope.$broadcast 'project:version:loaded', result

    #获取项目信息
    updateProject = (project_id)->
      project_id = $stateParams.project_id if !project_id
      API.project(project_id).retrieve().then (result)->
        $scope.project = result

    #更新成员列表信息
    $scope.$on "project:member:request", (event, project_id)-> updateProjectMember(project_id)
    $scope.$on "project:category:request", (event, project_id)-> updateProjectCategory(project_id)
    $scope.$on "project:version:request", (event, project_id)-> updateProjectVersion(project_id)
    $scope.$on "project:refresh:request", (event, project_id)-> updateProject(project_id)

    params =
      pageSize: 9999,
      myself: true
    API.project().retrieve(params).then (result)->
      $scope.projects = result

  ])


  .controller('myFollowController', ['$rootScope', '$scope', '$routeParams', '$location', '$stateParams', 'API', 'STORE',
  ($rootScope, $scope, $routeParams, $location, $stateParams, API, STORE)->
 #查询项目

    $scope.myproject = true;
    $scope.title = "我的关注";


    #更新项目成员
    updateProjectMember = (project_id)->
      project_id = $stateParams.project_id if !project_id
      API.project(project_id).member().retrieve().then (result)->
        $scope.projectMember = result
        STORE.projectMemberList.data = result

    #更新issue的分类
    updateProjectCategory = (project_id)->
      project_id = $stateParams.project_id if !project_id
      API.project(project_id).category().retrieve().then (result)->
        $scope.projectCategory = result
        STORE.projectCategory.data = result

    #获取版本信息
    updateProjectVersion = (project_id)->
      project_id = $stateParams.project_id if !project_id
      API.project(project_id).version().retrieve(status: 'available').then (result)->
        $scope.projectVersion = result
        STORE.projectVersion.data = result
        $rootScope.$broadcast 'project:version:loaded', result
    #获取项目信息
    updateProject = (project_id)->
      project_id = $stateParams.project_id if !project_id
      API.project(project_id).retrieve().then (result)->
        $scope.project = result

    #更新成员列表信息
    $scope.$on "project:member:request", (event, project_id)-> updateProjectMember(project_id)
    $scope.$on "project:category:request", (event, project_id)-> updateProjectCategory(project_id)
    $scope.$on "project:version:request", (event, project_id)-> updateProjectVersion(project_id)
    $scope.$on "project:refresh:request", (event, project_id)-> updateProject(project_id)

    params =
      pageSize: 9999
    API.project().retrieve(params).then (result)->
      $scope.projects = result

  ])





