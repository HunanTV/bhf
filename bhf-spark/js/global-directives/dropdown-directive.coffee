#git列表
'use strict'
define [
  '../ng-module'
  'utils'
], (_module, _utils) ->

  _module.directiveModule
  .directive('dropdown', ['$rootScope', ($rootScope)->
    restrict: 'A'
    replace: true
    link: (scope, element, attrs)->
      $self = $(element)
      $menus = $self.find 'div.dropdown'
      $text = $self.find attrs.textContainer
      exclude = (attrs.excludeValue || '').split(',')

      #同一时间只能打开一个dropdown
      scope.$on 'dropdown:show', (event, source)->
        return if source is element
        $menus.fadeOut()

      #设置选中的文本
      setText = (text)->
        text = _utils.formatString attrs.formatter || '{0}', text
        $text.text text

      $menus.bind 'mouseleave', -> $menus.fadeOut()
      $self.bind 'click', (e)->
        $menus.fadeIn()
        e.stopPropagation()

        #广播通知，dropdown显示
        $rootScope.$broadcast 'dropdown:show', element

        $('body').one 'click', -> $menus.fadeOut()


      attrs.$observe('selected', ->
        return if not scope.items
        if attrs.selected
          $current = $menus.find("a[data-value='#{attrs.selected}']")
          setText $current.text()
        else
          setText attrs.empty || ""
      )

      #scope.$broadcast 'dropdown:selected', attrs.name, selected

      $menus.bind 'click', (e)->
        e.stopPropagation()
        $this = $(e.target)
        $parent = $this.closest('a')
        $menus.fadeOut()

        #如果没有有指定data-value，则不处理
        value = $parent.attr('data-value')
        return if not value

        scope.$emit 'dropdown:selected', attrs.name, value

        setText $parent.text() if _.indexOf(exclude, value) is -1
  ])