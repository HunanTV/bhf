define [
  '../ng-module'
  '../utils'
  't!../../views/comment/comment-all.html'
], (_module,_utils, _template) ->

  _module.directiveModule
  #评论列表
  .directive('commentList', ['$rootScope', '$stateParams', 'API', '$timeout', ($rootScope, $stateParams, API, $timeout)->
    restrict: 'E'
    scope: data: '='
    replace: true
    template: _utils.extractTemplate '#tmpl-comment-list', _template
    link: (scope, element, attr)->
      searchComment = (pageIndex, cb)->
        API.project($stateParams.project_id)
        .issue($stateParams.issue_id)
        .comment()
        .retrieve({
          pageSize: 20
          pageIndex: pageIndex
        })
        .then((result)->
          scope.comments = result
          $timeout(hljs.initHighlighting,200)
        )

      #收到重新加载评论列表的事件
      scope.$on 'comment:list:reload', -> searchComment(1,null)

      $rootScope.$on 'pagination:change',(event, page, uuid, cb)->
        return if uuid isnt 'comment_list'
        searchComment(page)

      searchComment()
  ])

  #评论详细
  .directive('commentCell', ['$stateParams', 'API', 'NOTIFY', ($stateParams, API, NOTIFY)->
    restrict: 'E'
    scope: data: '=', '$index': '='
    replace: true
    template: _utils.extractTemplate '#tmpl-comment-cell', _template
    link: (scope, element, attr)->
      scope.onClickEdit = (event, comment)->
        return

      scope.onClickDelete = (event, comment)->
        return if not confirm('您确定要删除这个评论么，删除将无法恢复')
        API.project($stateParams.project_id).issue($stateParams.issue_id)
        .comment(comment.id).delete().then ->
          NOTIFY.success '删除评论成功'
          element.fadeOut()

        return
  ])

  #评论的编辑框
  .directive('commentEditor', ['$stateParams', '$timeout', 'API', ($stateParams, $timeout, API)->
    restrict: 'E'
    replace: true
    scope: {}
    template: _utils.extractTemplate '#tmpl-comment-editor', _template
    link: (scope, element, attrs)->
      activeClass = 'active'
      editorKey = 'comment'

      #重设编辑器的大小
      resizeCommentEditor = ()->
        element.css('width', element.parent().css('width')) if element.parent()


      #focus后，弹出大的编辑器
      scope.onFocusEditor = ()->
        issue_id = $stateParams.issue_id || null
        element.addClass activeClass
        scope.$broadcast 'editor:content', editorKey, issue_id, null, attrs.uploadUrl
        #绑定body的one事件，点击任何地方隐藏当前
        $('body').one 'click', -> scope.$broadcast 'editor:will:cancel', editorKey
        return true

      scope.$on 'editor:cancel', (event, name)->
        return if editorKey isnt name
        element.removeClass activeClass

      scope.$on 'editor:submit', (event, name, data)->
        return if editorKey isnt name
        element.removeClass activeClass

      #阻止click的冒泡
      element.bind 'click', (e)-> e.stopPropagation()

      #调整编辑器的大小
      $(window).on 'onResizeEx', resizeCommentEditor
      scope.$on '$destroy', -> $(window).off 'onResizeEx', resizeCommentEditor

      #立即监控resize会有问题，暂时用这种方式解决，未来需要调整
      $timeout(resizeCommentEditor, 1000)
  ])