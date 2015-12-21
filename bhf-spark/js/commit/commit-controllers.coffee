"use strict"
define [
  '../ng-module'
  '../utils'
], (_module, _utils) ->
  ###
    Modify:
      Author: ec.huyinghuan@gmail.com
      Date: 2015.07.16
      Describe:
        提取首次加载数据为一个函数，并且添加一个事件监听器刷新数据
  ###
  _module.controllerModule.
  controller('commitListController', ['$rootScope', '$scope', '$stateParams', 'API', ($rootScope, $scope, $stateParams, API)->
    cond = pageSize: 20
    loadData = ->
      API.project($stateParams.project_id).issue(0).commit()
      .retrieve(pageSize: 20).then((result)->
        $scope.commit = result
      )
    loadData()
    #同步完成，加载数据
    $scope.$on("commit:refresh:ready", ->
      loadData()
    )

    $scope.showImportModal = -> 
      $scope.$broadcast("commit:import:modal:show")

    $rootScope.$on 'pagination:change',(event, page, uuid, cb)->
      return if uuid isnt 'commit_pagination'
      API.project($stateParams.project_id).issue(0).commit().retrieve(pageSize: 20, pageIndex: page).then((result)->
        $scope.commit = result
      )
  ])

  #因gitlab的iframe策略，无法被引用
  .controller('commitDetailsController', ['$scope', '$sce', '$state', ($scope, $sce, $state)->
    $scope.url = $sce.trustAsResourceUrl($state.params.url)
  ])