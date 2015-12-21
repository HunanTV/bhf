'use strict'

define [
  '../ng-module'
  '../utils'
  't!../../views/report/report-all.html'
], (_module,_utils, _template) ->

  _module.directiveModule
#  周报明细中，每个用户的周报数据
  .directive('reportWeeklyDetailsMember', [->
    restrict: 'E'
    replace: true
    scope: source: '='
    template: _utils.extractTemplate '#tmpl-report-weekly-details-member', _template
    link: (scope, element, attrs)->

  ])

  .directive('reportTeamCategoryMenu', [->
    restrict: 'E'
    replace: true
    template: _utils.extractTemplate '#tmpl-report-team-menu-category', _template
    link: (scope, element, attrs)->

  ])

  .directive('reportWeeklyDetailsContent', [->
    restrict: 'E'
    replace: true
    template: _utils.extractTemplate '#tmpl-report-weekly-details-content', _template
    link: (scope, element, attrs)->

  ])

  .directive('reportWeeklyDetailsPrint', [->
    restrict: 'E'
    replace: true
    template: _utils.extractTemplate '#tmpl-report-weekly-details-print', _template
    link: (scope, element, attrs)->

  ])

  .directive('indexTeamFinishedChart', ["API", (API)->
    restrict: 'E'
    replace: true
    template: _utils.extractTemplate '#tmpl-index-team-finished-chart', _template
    link: (scope, element, attrs)->
      API.team().retrieve({status:1}).then (result)->
        scope.teams = if result then result else []
        scope.current_team = if scope.teams.length > 0 then scope.teams[0] else 0

      scope.teamClick = (team)->
        scope.current_team = team
        scope.$broadcast "team:chart:change", team.team_id, "team"
  ])


  .directive('reportCreate', ["WEEKLIST", "API", "NOTIFY", (WEEKLIST, API, NOTIFY)->
    restrict: 'E'
    replace: true
    template: _utils.extractTemplate '#tmpl-report-create', _template
    link: (scope, element, attrs)->
      scope.weekList = WEEKLIST(5)
      scope.profile = {}
      scope.profile.time = scope.weekList[0].start
      $o = $(element)
      #接收事件后，加载数据并显示
      scope.$on 'report:create:show', (event)->
        $o.modal showClose: false
        
      scope.$on 'report:create:hide', ()->
        $.modal.close()

      scope.dropDownChange = ()->
        API.report().retrieve(time: scope.profile.time).then (result)->
          scope.profile.content = result.content
          scope.profile.id = result.id

      scope.onClickSave = ()->
        isEdit = false
        reportAPI = API.report()
        method = if !scope.profile.id then 'create' else 'update'
        reportAPI[method](scope.profile).then (res)->
          NOTIFY.success '保存成功！'
          scope.$emit "report:create:hide"
      
      scope.onClickCancel = ()->
        scope.$emit "report:create:hide"

      scope.dropDownChange()

  ])

  