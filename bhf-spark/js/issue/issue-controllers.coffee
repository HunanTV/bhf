"use strict"
define [
  '../ng-module'
  '../utils'
], (_module, _utils, _template) ->

  _module.controllerModule.
  #issue明细
  controller('issueDetailsController', ['$scope', '$stateParams', 'API', '$state', '$timeout', 
  ($scope, $stateParams, API, $state, $timeout)->
    $scope.articleOnly = $state.current.data?.articleOnly
    issueLoad = ()->
      API.project($stateParams.project_id)
      .issue($stateParams.issue_id)
      .retrieve().then((result)->

        $scope.issue = result
        $scope.notFound = !result
        $scope.$emit 'project:member:request', $scope.issue.project_id if !$scope.projectMember or $stateParams.project_id isnt $scope.issue.project_id
        $scope.$emit 'project:category:request', $scope.issue.project_id if !$scope.projectCategory or $stateParams.project_id isnt $scope.issue.project_id
        $scope.$emit 'project:version:request', $scope.issue.project_id if !$scope.projectVersion or $stateParams.project_id isnt $scope.issue.project_id
        $scope.$emit 'project:refresh:request', $scope.issue.project_id if !$scope.projectVersion or $stateParams.project_id isnt $scope.issue.project_id

        $timeout(hljs.initHighlighting, 100)
        
      )

    $scope.$on "assets:upload:finish", ()->
      $scope.$broadcast "assets:list:update"
      return


    $scope.$on "issue:detail:reload", ()->
      issueLoad()
      return 
      
    issueLoad()
  ])

  #讨论列表
  .controller('discussionListController', ['$scope', '$stateParams', '$location', '$filter', 'API'
  ($scope, $stateParams, $location, $filter, API)->
    $scope.condition = {}

    loadDiscussion = ()->
      API.project($stateParams.project_id).discussion()
      .retrieve($scope.condition).then (result)->
        $scope.discussion = result

    $scope.$on 'issue:change', (event, data)->
      loadDiscussion()
      return if data.status isnt 'new'

      url = "/#{$filter('projectLink')(null, 'normal')}/discussion/#{data.id}"
      $location.path(url).search('editing', 'true')

    $scope.$on 'instant-search:change', (event, value)->
      return if $scope.condition.keyword is value

      $scope.condition.keyword = value
      loadDiscussion()

    loadDiscussion()
  ])


  #评论列表
  .controller('commentListController', ['$scope', '$stateParams', 'API',
  ($scope, $stateParams, API)->

  ])

#  #文档列表
  .controller('documentListController', ['$rootScope', '$scope', '$stateParams', '$location', '$filter', 'API',
  ($rootScope, $scope, $stateParams, $location, $filter, API)->
    cond = tag: 'document',pageSize: 20

    loadDocument = (pageIndex)->
      cond.pageIndex = pageIndex if pageIndex
      API.project($stateParams.project_id).issue().retrieve(cond).then (result)->
        $scope.document = result

    $scope.$on 'issue:change', (event, data)->
      loadDocument()
#      return if data.status isnt 'new'
#      url = "/#{$filter('projectLink')(null, 'normal')}/document/#{data.id}"
#      $location.path(url).search('editing', 'true')


    $rootScope.$on 'pagination:change',(event, page, uuid, cb)->
      return if uuid isnt 'document_pagination'
      loadDocument(page)
    loadDocument()
  ])

  .controller('documentDetailsController', ['$state', '$scope', ($state, $scope)->


  ])

  #表单
  # .controller('formController', ['$scope', '$stateParams', 'API',
  # ($scope, $stateParams, API)->
  #   $scope.template=$stateParams.template
    
  # ])

