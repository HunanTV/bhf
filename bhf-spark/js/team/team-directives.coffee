'use strict'

define [
  '../ng-module'
  '../utils'
  't!../../views/team/team-all.html'
  'v/circles'
], (_module,_utils, _tmplAll) ->

  _module.directiveModule.directive('teamCategoryMenu', ['STORE', ()->
    restrict: 'E'
    replace: true
    template: _utils.extractTemplate '#tmpl-team-menu-category', _tmplAll
    link: (scope, element, attrs)->

  ])
  .directive('teamInviteMenu', ['STORE', ()->
    restrict: 'E'
    replace: true
    template: _utils.extractTemplate '#tmpl-team-menu-invite', _tmplAll
    link: (scope, element, attrs)->

  ])
  .directive('teamMenuBar', [()->
    restrict: 'E'
    replace: true
    template: _utils.extractTemplate '#tmpl-team-menu-bar', _tmplAll
    link: (scope, element, attrs)->
    	
  ])
  .directive('teamCreate', ['API', (API)->
    restrict: 'AC'
    link: (scope, element, attrs)->
      $this = $(element) 
      addTeam = (member_id)->
        data = {name: $this.val()}
        API.team().create(data).then (team)->
          window.location.href = "/team/#{team.id}/list?title=#{team.name}"
      $this.on "keyup", (event)->
        if event.keyCode is 13 and $this.val() then addTeam() 
  ])
  .directive('teamInviteItem', ['API', 'NOTIFY', (API, NOTIFY)->
    restrict: 'E'
    replace: true
    template: _utils.extractTemplate '#tmpl-team-invite-item', _tmplAll
    link: (scope, element, attrs)->
      scope.inviteAccept = (team,flag)->
        method = ["update", "delete"]
        entity = 
          status: 1
        memberAPI = API.team(team.team_id).member(team.member_id)
        memberAPI[method[flag]](entity).then (result)->
          NOTIFY.success '操作成功！'
          scope.$emit "team:category:request"
  ])
				
  .directive('teamSetting', ['$location', 'API', 'NOTIFY', ($location, API, NOTIFY)->
    restrict: 'E'
    replace: true
    scope: {}
    template: _utils.extractTemplate '#tmpl-team-setting', _tmplAll
    link: (scope, element, attr)->
      $o = $(element)
      #接收事件后，加载数据并显示
      scope.$on 'team:setting:show', (event, name, id)->
        $o.modal showClose: false
        scope.isEdit = name || id
        scope.profile = 
          teamName: name
          team_id: id
      scope.$on 'team:setting:hide', ()->
        $.modal.close()

      
      scope.onClickCancel = ()->
        scope.$emit "team:setting:hide"

      scope.onClickSave = ()->
        return if scope.profile.teamName is scope.title
        entity =
          name: scope.profile.teamName
        method = "create"
        method = "update" if scope.isEdit
        API.team(scope.profile.team_id)[method](entity).then (result)->
          NOTIFY.success '保存成功！'
          scope.profile = {}
          $.modal.close()
          $location.url("/team/#{result.id}/list?title=#{result.name}") if result.id

      scope.onClickDelete = ()->
        scope.$emit "team:remove" if confirm "要不要再考虑一下呢？" if confirm "你真的确定要删除该团队了吗？" if confirm "删除团队后，团队的成员关系将不复存在，请慎重操作！"
        
  ])