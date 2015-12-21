###
  简单的tab实现
  调用：$(expr).simpleTab(options)
  切换到指定的标签tab
  $(expr).simpleTab('change', target); //其中target可以是索引或者命名
  options：请参考defaultOptions

  HTML的格式如下：
  <div class="tab" tab>
      <ul class="nav" data-field="nav">
          <li class="active">menu 1</li>
          <li>menu 1</li>
          <li>menu 1</li>
      </ul>
      <div class="content" data-field="content">
          <div>panel 1</div>
          <div>panel 2</div>
          <div>panel 3</div>
      </div>
  </div>
###

(($)->
  class SimpleTab
    constructor: ($container, options)->
      defaultOptions =
        #查找导航容器的表达式
        navExpr: '[data-field="nav"]'
        #查找panel容器的表达式
        panelExpr: '[data-field="content"]'
        #触发tab切换的事件类型
        eventName: 'click'
        #活动的class
        activeClass: 'active'
        #指定活动的面版（可以是索引或者名字），如果没有指定，则查找activeClass，如果没有指定activeClass，则取第一个panel
        activePanel: null

      @options = $.extend defaultOptions, options

      @initElements $container
      @initSelected()

    #初始化标签
    initElements: ($o)->
      self = @
      ops = @options
      els = @elements =
        menus: $o.find ops.navExpr
        panels: $o.find ops.panelExpr

      els.menus.children().bind ops.eventName, ->
        $this = $(this)
        target = $this.attr('data-value') || $this.index()
        self.change target


    initSelected: ()->
      #已经指定默认显示的面版
      return @change @options.activePanel if @options.activePanel

      #没有指定，则查找active
      els = @elements
      $current = els.menus.find(">.#{@options.activeClass}")
      $current = els.menus.eq(0) if $current.length is 0
      @change $current.index()

    #切换到指定的标签
    change: (target)->
      klass = @options.activeClass
      els = @elements
      useIndex = typeof target is 'number'
      expr = if useIndex then ">:eq(#{target})" else ">[data-value='#{target}']"
      els.menus.find(">.#{klass}").removeClass(klass)
      index = els.menus.find(expr).addClass(klass).index()
      els.panels.find('>*').hide()
      #如果有指定名称，则查找名称，否则使用索引的方式
      els.panels.find(expr).show()


  SimpleTab.publicMethods = ['change']


  $.fn.simpleTab = (arg, args...)->
    storeKey = 'honey.tab'
#    仅允许调用公开的方法
    if typeof(arg) is 'string' and arg in SimpleTab.publicMethods
      instance = this.data storeKey
      return console.log('Plugin or Method not defined.') if not instance or not instance[arg]
      return instance[arg].apply instance, args

    #实例化
    instance = new SimpleTab(this, arg)
    this.data storeKey, instance
    this

)($ || window.jQuery || window.jquery)