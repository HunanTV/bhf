define [
  '../ng-module'
  '../utils'
  't!../../views/issue/issue-all.html'
  't!../../views/issue/issue-form.html'
], (_module,_utils, _template,_templateForm) ->

  _module.directiveModule
  .directive('issueListCell', ['$rootScope','$location', '$filter', 'API', ($rootScope,$location, $filter, API)->
    restrict: 'E'
#    scope: data: '='
    replace: true
    template: _utils.extractTemplate '#tmpl-issue-list-cell', _template
    link: (scope, element, attrs)->

      scope.onClickIssue = (event, issue)->
        if $location.$$url.indexOf("/myproject/") > -1
          $location.path $location.$$url.split('?')[0].split("/myself")[0] + "/myself/" + issue.id
        else if $location.$$url.indexOf("/myfollow/") > -1
          $location.path $location.$$url.split('?')[0].split("/follow")[0] + "/follow/" + issue.id
        else
          baseUrl = $filter('projectLink')(issue, issue.tag)
          $location.path "#{baseUrl}/#{issue.id}"
        scope.$emit "project:window:change",2

      #点击状态
      scope.onClickStatus = (event, issue)->
        scope.$emit 'issue:status-dropdown:show', event, issue
        return

      scope.getDelayClass = (issue)->
        if issue.plan_finish_time and
          issue.status isnt 'done' and
          issue.plan_finish_time < new Date().valueOf() then 'delay' else ''

      #收到更改状态的通知
      scope.$on 'dropdown:selected', (event, type, value)->
        return if type isnt 'issue:status'
        #"project/#{scope.issue.project_id}/issue/#{scope.issue.id}/status"


        API.project(scope.issue.project_id).issue(scope.issue.id).update(status : value).then ()->
              scope.$emit 'issue:change', 'status', scope.issue.id


#          动画需要考虑多个问题，暂缓
#          #执行一个动画，完毕后重新加载数据
#          $obj = $("#issue-list-#{scope.issue.id}")
#          top = $('#issue-list-done').offset().top
#
#          optoins =
#            y: top
#            duration: 800
#            complete: ->
#              scope.$emit 'issue:list:reload'
#
#          $obj.transition(optoins)

  ])

  .directive('issuePriorityDropdown', [()->
    restrict: 'E'
    replace: true
    template: _utils.extractTemplate '#tmpl-issue-priority-dropdown', _template
    link: (scope, element, attrs)->
  ])

  #issue的下拉列表
  .directive('issueStatusDropdown',[()->
    restrict: 'E'
    replace: true
    scope: {}
    template: _utils.extractTemplate '#tmpl-issue-status-dropdown', _template
    link: (scope, element, attrs)->

  ])

  #issue的下拉列表
  .directive('issueSplitStatusDropdown',[()->
    restrict: 'E'
    replace: true
    scope: {}
    template: _utils.extractTemplate '#tmpl-issue-status-dropdown', _template
    link: (scope, element, attrs)->

  ])

  #issue 状态下拉列表，下拉列表必需已经存在容器内容，并且可以通过find('div.dropdown.status')找得到
  .directive('issueStatusDropdownAction',[()->
    restrict: 'A'
    replace: false
#    scope: {}
#    template: _utils.extractTemplate '#tmpl-issue-status-dropdown', _template
    link: (scope, element, attrs)->
      $dropdown = null
      currentIssue = null

      scope.$on 'issue:status-dropdown:show', (ngEvent, event, issue)->
        event.stopPropagation()
        currentIssue = issue
        statusVisibility issue

        $this = $(event.target)
        position = $this.position()
        position.top += $this.height()
        position.left -= 6;
        $dropdown.css(position).fadeIn()
        $('body').one 'click', -> $dropdown.fadeOut()
        return

      initDropdown = ()->
        return if $dropdown

        $dropdown = $(element).find 'div.dropdown.status'
        $dropdown.bind 'mouseleave', -> $dropdown.fadeOut()
        $dropdown.find('a').bind 'click', ()->
          $this = $(this)
          value = $this.attr 'data-value'
          # 是否为拆分任务，拆分任务有issue_id
          type = currentIssue.issue_id?
          scope.$emit 'issue:status:change', currentIssue.id, currentIssue.status, value, type

      #设置状态是否可视
      statusVisibility = (issue)->
        isTest = issue.tag is 'test'
        displayRules =
          doing: true
          pause: issue.status isnt 'done'
          repaired: isTest and issue.status is 'repairing'
          repairing: isTest and issue.status in ['doing', 'reviewing', 'repaired']
          reviewing: isTest and issue.status in ['doing', 'repairing', 'repaired']
          done: not isTest and issue.status isnt 'done'
          reviewed: isTest and issue.status is 'reviewing'


        initDropdown()
        $dropdown.find('li').each ()->
          $this = $(this)
          value = $this.attr('data-status')
          $this.toggle displayRules[value]

  ])

  #快速编辑的功能
  .directive('issueQuickEditor', ['$rootScope', '$state', '$stateParams', '$location', '$timeout',  'API', 'NOTIFY',
  ($rootScope, $state, $stateParams, $location, $timeout, API, NOTIFY)->
    restrict: 'A'
    replace: true
    link: (scope, element, attrs)->
#      console.log($location)
      titleMap =
        issue: '任务'
        document: '文档'
        discussion: '讨论'
        test: '测试'

      #跳转到具体的issue
      gotoIssue = (issue_id)->
        #替换掉url后面可能存在的id
        url = $location.$$path.replace(/(.+)(\/\d+)$/, '$1') + '/' + issue_id
        $location.path(url)

        #延时打开编辑器，但这样做好吗？
        #这个地方的问题在于，跳转到url后，需要加载完issue，才能显示editor，这样就需要多个事件交互
        $timeout (-> $rootScope.$broadcast('issue:editor:show')), 1000

      scope.onKeyDown = (event)->
        return if event.keyCode isnt 13
        #处理回车
        text = _utils.trim(event.target.value)
        return if not text

        data =
          tag: attrs.tag
          title: text
          category_id: $stateParams.category_id
          version_id: $stateParams.version_id

        API.project(scope.project.id).issue().create(data).then (result)->
          NOTIFY.success "创建#{titleMap[attrs.tag]}成功"
          event.target.value = null
          #通知issue被创建
          scope.$emit 'issue:change', {status: 'new', tag: attrs.tag, id: result.id}
          #跳转
          gotoIssue result.id


      scope.createForm = (form)->
        # console.log $scope
        form=$stateParams.category_id
        scope.$broadcast 'issue:form:show', -1, form
  ])


  #用户日志
  .directive('issueLog', ['$stateParams', 'API', ($stateParams, API)->
      restrict: 'E'
      replace: true
      scope: {}
      template: _utils.extractTemplate '#tmpl-issue-log', _template
      link: (scope, element, attrs)->

        API.project($stateParams.project_id)
        .issue($stateParams.issue_id)
        .log().retrieve().then (result)->
          scope.logs = result.items

  ])

  #任务标签的下拉列表
  .directive('issueTagDropdown', ['$stateParams', 'API', 'NOTIFY', ($stateParams, API, NOTIFY)->
    restrict: 'E'
    replace: true
    template: _utils.extractTemplate '#tmpl-issue-tag-dropdown', _template
    link: (scope, element, attrs)->

      scope.$on 'dropdown:selected', (event, type, value)->
        return if type isnt 'issue:tag'
        API.project($stateParams.project_id)
        .issue($stateParams.issue_id)
        .update(tag: value).then ->
          NOTIFY.success "修改成功"



  ])

  #issue列表
  .directive('issuePlainList', [->
    restrict: 'E'
    replace: true
#    scope: source: '@', title: '@'
    scope: title: '@', emptyMemo: '@', showDetails: '@', needPagination: "@", uuid: "@"
    template: _utils.extractTemplate '#tmpl-issue-plain-list', _template
    link: (scope, element, attrs)->
#      scope.$watch 'source', ()->
#        return if not scope.source
#        scope.source = JSON.parse(scope.source)

      scope.emptyMemo = scope.emptyMemo || "#{scope.title}的任务为空"

      scope.onClickToggle = ()-> scope.showDetails = !scope.showDetails

      attrs.$observe('source', ->
        return if not attrs.source
        scope.source = JSON.parse(attrs.source)
      )
  ])

# $compile(element.contents())(scope);

  # 表单
  .directive('issueForm', ['$rootScope', '$stateParams', '$compile', 'API', 'NOTIFY', ($rootScope, $stateParams, $compile, API, NOTIFY)->
      restrict: 'E'
      replace: true
      scope: type: '@',issue: '@',editflag: '@',change:'@'
      link: (scope, element, attrs)->
        #  scope.issue等于-1时，是新建表单；其他的是预览已存在的表单；
        if scope.issue isnt -1 and $stateParams.issue_id isnt null
          API.project($stateParams.project_id).issue($stateParams.issue_id).retrieve().then (result)->
            return if result.tag isnt "form"
            scope.entity=JSON.parse(result.content)
            scope.title=result.title
            type=scope.entity.uuid
            # 动态加载表单
            temp =  _utils.extractTemplate ["#temp-form-head", "#tmpl-issue-form-#{type}", "#temp-form-foot"], _templateForm
            temp = temp.replace(/&lt;/g, "<").replace(/&gt;/g, ">")
            element.html temp
            $compile(element.contents())(scope)

        #  表单可编辑状态
        scope.editable = scope.editflag isnt '-1'

        # 响应父级保存按钮
        scope.$on 'issue:form:submit', (event)->
          if !scope.myForm.$valid
            NOTIFY.error "请检查必填项是否漏填！"
            return
          params =
            tag: "form"
            title: scope.entity.name + '-' + scope.entity.department + '-' + scope.entity.title
            category_id: $stateParams.category_id
            content: JSON.stringify(scope.entity)
          params.title = scope.entity.title if !scope.entity.name 

          # issue等于-1的时候为新增
          isEdit = scope.issue is '-1'
          issueAPI = API.project($stateParams.project_id).issue(if isEdit then '' else $stateParams.issue_id)
          method = if isEdit then 'create' else 'update'
          issueAPI[method](params).then ->
             NOTIFY.success "保存#{params.title}成功"
             scope.$emit 'issue:list:reload'
             scope.$emit 'issue:form:hide'

          # if scope.issue == '-1'
          #   params.title = scope.entity.name+'-'+scope.entity.department+'-'+scope.entity.title
          #   params.category_id = $stateParams.category_id
          #   API.project($stateParams.project_id).issue().create(params).then (result)->
          #     NOTIFY.success "创建#{params.title}成功"
          #     scope.$emit 'issue:form:hide'
          # else
          #   params.title = scope.title
          #   params.category_id = $stateParams.category_id
          #   API.project($stateParams.project_id).issue($stateParams.issue_id).update(params).then (result)->
          #     NOTIFY.success "修改#{params.title}成功"
          #     scope.$emit 'issue:form:hide'

        # 弹窗触发事件
        scope.$on 'issue:form:change', (event,issueId,index)->
          # 如果不是弹窗则返回
          return if scope.change is '-1'            
          # 处理编辑状态
          scope.editable = scope.editflag isnt '-1'
          temp = _utils.extractTemplate ["#temp-form-head", "#tmpl-issue-form-#{index}", "#temp-form-foot"], _templateForm
          temp = temp.replace(/&lt;/g, "<").replace(/&gt;/g, ">")
          element.html temp
          scope.entity = {}                 
          if issueId isnt -1
            API.project($stateParams.project_id).issue($stateParams.issue_id).retrieve().then (result)->
              scope.entity=JSON.parse(result.content)
              scope.title=result.title
          else
            scope.entity.uuid = index 
            # scope.entity.name   
          $compile(element.contents())(scope)

  ])


  .directive('issueFormModal', ['$timeout', ($timeout)->
      restrict: 'E'
      replace: true
      template: _utils.extractTemplate "#tmpl-issue-form-modal", _templateForm 
      scope:{}
      link: (scope, element, attrs)->
        scope.btname=1;
        scope.issueId=-1

        # 表单提交
        scope.onClickSubmit = ()->
          scope.$broadcast 'issue:form:submit'

        scope.onClickCancel = ()->
          scope.$emit 'issue:form:hide'

        #接收事件后，加载数据并显示
        scope.$on 'issue:form:show', (event, issueId, index)->
          # console.log 'receive'
          scope.activeIndex = index
          scope.issueId=issueId
          # scope.title='表单'        
          $o = $(element)
          $timeout (-> $o.modal showClose: false), 200
          scope.$broadcast 'issue:form:change',issueId,index
        scope.$on 'issue:form:hide', (event)->
          $.modal.close()
  ])

  .directive('windowChangeButton', [->
      restrict: 'E'
      replace: true
      template: "<button class='primary default' ng-click='windowChange()'>返回列表</button>"
      scope:{}
      link: (scope, element, attrs)->

        scope.windowChange = ()->
          scope.$emit "project:window:change", 1
  ])


  .directive('uploadDocx', ['$rootScope', '$stateParams', 'API', 'NOTIFY', ($rootScope, $stateParams, API, NOTIFY)->
    restrict: 'A'
    replace: true
    link: (scope, element, attr)->
      # $progress = $(element).find '.progress'
      # $percent = $(element).find '.percent'
      # $mask = $(element).find '.mask'

      filterFn = (file, info)->
        confirmSize = Math.pow(2, 28)
        maxSize = Math.pow(2, 30)
        #超过256M则提示
        if file.size > confirmSize
          return confirm('上传大文件浏览器可能会出现卡死的情况，你确定要上传么')
        else if file.size > maxSize
          alert("上传文件不能超过#{maxSize / 1024 / 1024}M")
          return false

        return true

      # resetProgress = ()->
      #   $progress.text('0%')
      #   $percent.css('width', '0')
      #   $mask.hide()

      #上传的回调
      uploadFn = (files, rejected)->
        if files.length is 0
          NOTIFY.warn '无可上传的文件'
          return

        # $mask.show()
        FileAPI.upload
          url: "/api/project/#{$stateParams.project_id}/#{$stateParams.version_id}/#{$stateParams.category_id}/issue/create/assets"
          files: assets: files
          #完成后的操作
          complete: (err, xhr)->
            # resetProgress()
            # scope.$emit "assets:upload:finish"
            return NOTIFY.error '文件上传失败' if err

            NOTIFY.success '所有文件已经上传成功啦'

            $rootScope.$broadcast 'issue:list:reload'

          #进度
          progress: (event, file, xhr, options)->
#             percent = (event.loaded / event.total * 100)
# #            console.log percent
#             $progress.text percent.toFixed(2) + '%'
#             $percent.css('width', percent + '%')
      #延时加载上传文件
      require ['v/FileAPI.html5'], ->
        target = element[0]
        FileAPI.event.on target, 'change', (event)->
          files = FileAPI.getFiles(event)
          FileAPI.filterFiles files, filterFn, uploadFn
  ])


  #项目关注成员的下拉列表
  .directive('issueFollowMemberDropdown',['API', 'NOTIFY',(API, NOTIFY)->
    restrict: 'E'
    replace: true
    template: _utils.extractTemplate '#tmpl-issue-follow-member-dropdown', _template
    link: (scope, element, attrs)->
      loaded = false

      #获取到数据后，调用dropdown
      attrs.$observe('items', ->
        #异步获取数据时，items可能还没有赋值，也可能被多次赋值
        return if loaded or not attrs.items
        loaded = true
        scope.items = _utils.toDyadicArray JSON.parse(attrs.items), 15
      )

      scope.$on 'dropdown:selected', (event, type, value)->
        return if type isnt 'issue:follow'
        #"project/#{scope.issue.project_id}/issue/#{scope.issue.id}/status"
        API.project(scope.issue.project_id).issue(scope.issue.id).follow().create(member_id : value).then (res)->
          scope.$emit "issue:follow:change"
          NOTIFY.success '关注成功'
  ])

  # .directive('issueFormButton',['$stateParams',($stateParams)->
  #   restrict: 'A'
  #   replace: false
  #   template:'<span>{{btname}}</span>'
  #   scope:{}
  #   link: (scope, element, attrs)->
  #     scope.btname=$(_utils.extractTemplate "#tmpl-issue-form-#{$stateParams.category_id}", _templateForm).eq(0).html() 
  # ])


  #项目关注成员列表
  .directive('issueFollowMembers',['$stateParams', 'API', 'NOTIFY', ($stateParams, API, NOTIFY)->
    restrict: 'E'
    replace: true
    template: _utils.extractTemplate '#tmpl-issue-follow-members', _template
    link: (scope, element, attrs)->
      followAPI = API.project($stateParams.project_id).issue($stateParams.issue_id).follow()

      refreshFollow = ()->
        followAPI.retrieve().then (res)->
          scope.followMembers = res

      scope.removeFollow = (member)->
        followAPI.delete(id: member.member_id).then (res)->
          scope.$emit "issue:follow:change"
          NOTIFY.success '取消关注成功'

      scope.$on "issue:follow:change", (event)->
        refreshFollow()

      refreshFollow()
  ])


  #项目关注按钮
  .directive('issueFollowIcon',['$stateParams', 'API', 'NOTIFY', ($stateParams, API, NOTIFY)->
    restrict: 'E'
    replace: true
    template: _utils.extractTemplate '#tmpl-issue-follow-icon', _template
    link: (scope, element, attrs)->
      followAPI = API.project($stateParams.project_id).issue($stateParams.issue_id).follow()

      scope.clickFollow = (follow)->
        if follow is 1
          followAPI.delete().then (res)->
            scope.$emit "issue:follow:change"
            scope.issue.follow = 0
            NOTIFY.success '取消关注成功'
        else
          followAPI.create().then (res)->
            scope.$emit "issue:follow:change"
            scope.issue.follow = 1
            NOTIFY.success '关注成功'
  ])


  #项目关注成员列表
  .directive('issueSplit',['$rootScope', '$stateParams', '$timeout', 'API', 'NOTIFY', ($rootScope, $stateParams, $timeout, API, NOTIFY)->
    restrict: 'E'
    replace: true
    template: _utils.extractTemplate '#tmpl-issue-split', _template
    link: (scope, element, attrs)->
      issueAPI = API.project($stateParams.project_id).issue($stateParams.issue_id)

      scope.recentSplit = {}

      scope.$on 'datetime:change', (event, name, date)->
        return if name.indexOf('plan_finish_time_') is -1

        issueAPI.split(name.split('_').pop()).update(plan_finish_time:date).then (result)-> 
          $rootScope.$broadcast 'issue:detail:reload' if result

      scope.blur=()->
        scope.splitShow = false;
        scope.recentSplit = {};

      scope.splitSave = ()->
        return if event.keyCode isnt 13
        splitAPI = issueAPI.split()
        splitAPI = issueAPI.split(scope.recentSplit.id) if scope.recentSplit.id
        method = if scope.recentSplit.id then 'update' else 'create'

        splitAPI[method](scope.recentSplit).then (result)->
          NOTIFY.success '保存成功'
          scope.recentSplit = {}
          $rootScope.$broadcast 'issue:detail:reload'



      scope.splitEdit = (item)->
        $timeout (-> $("#split-text").focus()), 100
        scope.splitShow = true;
        scope.recentSplit = item


      scope.splitDelete = (item)->
        return if not confirm('您确定要删除这个子任务吗？')
        issueAPI.split(item.id).delete().then (result)->
          $rootScope.$broadcast 'issue:detail:reload' if result


  ])
    


  #项目关注成员的下拉列表
  .directive('issueSplitMemberDropdown',['$stateParams', 'API', 'NOTIFY',($stateParams, API, NOTIFY)->
    restrict: 'E'
    replace: true
    template: _utils.extractTemplate '#tmpl-issue-split-member-dropdown', _template
    link: (scope, element, attrs)->
      loaded = false

      #获取到数据后，调用dropdown
      attrs.$observe('items', ->
        #异步获取数据时，items可能还没有赋值，也可能被多次赋值
        return if loaded or not attrs.items
        loaded = true
        scope.items = _utils.toDyadicArray JSON.parse(attrs.items), 15
      )

      scope.$on 'dropdown:selected', (event, type, value)->
        return if type.indexOf('issue:split') is -1
        API.project($stateParams.project_id).issue($stateParams.issue_id).split(type.split(':').pop()).update({owner:value}).then ()->
       
  ])
    
