"use strict"
define [
  '../ng-module'
  '../utils'
  '_'
], (_module, _utils, _) ->

  _module.controllerModule.
  controller('assetsListController', ['$rootScope', '$scope', '$stateParams', 'API',
  ($rootScope, $scope, $stateParams, API)->
    $scope.condition = {}

    searchAssets = (query)->
      $scope.condition = _.extend {pageSize: 20}, query
      API.project($stateParams.project_id).assets()
      .retrieve($scope.condition).then((result)->
        $scope.assets = result
      )
    $rootScope.$on 'pagination:change',(event, page, uuid, cb)->
      return if uuid isnt 'asset_pagination'
      searchAssets({pageIndex:page})


    $scope.$on 'instant-search:change', (event, keyword)->
      return if $scope.condition.keyword is keyword
      searchAssets keyword: keyword

    searchAssets()
  ])

  .controller('assetsDetailsController', ['$scope', '$stateParams', '$filter', 'API',
  ($scope, $stateParams, $filter, API)->
    API.project($stateParams.project_id).issue(0).assets($stateParams.asset_id).retrieve().then (result)->
      $scope.asset = result
      #压缩文件
      if $scope.assetIsBundle = $filter('assetIsBundle')(result.file_name)
        $scope.$broadcast 'asset:bundle:load', result
      else
        $scope.assetType = _utils.detectFileType result.original_name
  ])