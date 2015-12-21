#git列表
'use strict'
define [
  '../ng-module'
  '../utils'
  '_'
  't!../../views/global-all.html'
], (_module, _utils, _, _tmplGlobal) ->

  _module.directiveModule.directive('gitListEditor', ['NOTIFY', (NOTIFY)->
    restrict: 'E'
    replace: true
    scope:  bean: '=', maxCount: '@', expression: '@'
    template: _utils.extractTemplate '#tmpl-global-git-list', _tmplGlobal
    link: (scope, element, attrs)->

      #校验用户输入的正则表达式
      testExpr = new RegExp(scope.expression)

      #允许存储的最大git账户数量
      maxCount =  parseInt scope.maxCount
      #保存编辑状态 -1表示非编辑状态
      nowEditingIndex = -1

      #添加一条git账户数据
      addGitAccount = (account)->
        return if scope.gitAccounts.length >= maxCount
        scope.gitAccounts.push account
        updateGitAccount()

      updateGitAccount = (account = [])->
        scope.bean.setGits(scope.gitAccounts.concat(account))

      #给input 赋值
      bindDataForInput = (value)-> $(element).find("input").val value

      #初始化绑定
      scope.$on('gitList:load', (e, data)->
        scope.currentText = ""
        scope.gitAccounts = data or []
        updateGitAccount()
      )

      #回车 动作添加git账户
      scope.onKeypressAdd = (event)->
        return if event.keyCode isnt 13
        event.preventDefault()
        account = _utils.trim event.currentTarget.value

        return if account is ''
        #检测用户输入是否合法
        return NOTIFY.error('您输入的内容不合法') if not testExpr.test(account)

        if _.indexOf(scope.gitAccounts, account) > -1
          bindDataForInput ''
          return

        if nowEditingIndex is -1
          addGitAccount account
        else
          scope.gitAccounts[nowEditingIndex] = account

        bindDataForInput ''
        nowEditingIndex = -1
        return

      scope.onKeyupAddLastItem = (event)->
        return if event.keyCode is 13
        return if nowEditingIndex isnt -1
        account = _utils.trim event.currentTarget.value
        return updateGitAccount() if account is ''
        return updateGitAccount() if not testExpr.test(account)
        updateGitAccount(account)

      scope.onClickRemove = (event, index)->
        scope.gitAccounts.splice index, 1
        nowEditingIndex = -1
        updateGitAccount()
        return

      scope.onClickEdit = (event, index, account)->
        nowEditingIndex = index
        bindDataForInput account
        return
  ])