((factory)->
  if (typeof define is 'function') and define.amd
    define ['simditor'], factory
  else
    factory window.Simditor
)((Simditor)->
  class FullScreenButton extends Simditor.Button
    constructor: ->
      @isExpand = false
      super

    _init: ->
      @shortcut = 'esc'
      super
      @setIcon("expand")

    name: 'fullscreen'
    title: 'full-screen'

    #保存expand之前的状态
    saveStatus: ->
      el = @editor.el
      wrapper = @editor.wrapper
      toolbar = @editor.toolbar
      body = @editor.body
      @cssStatus =
        el:
          position: el.css('position')
          left: el.css('left')
          right: el.css('right')
          top: el.css('top')
          bottom: el.css('bottom')
        wrapper: wrapper.css("height")
        toolbar:
          wrapper:
            width: toolbar.wrapper.css("width")
        body:
          maxHeight: body.css("maxHeight")
          overflow: body.css("overflow")

    setIcon: (icon)->
      @el.find("span").removeClass().addClass("fa fa-#{icon}")

    #恢复到expand之前的状态
    resetStatus: ->
      @editor.el.css(@cssStatus.el)
      @editor.wrapper.css(@cssStatus.wrapper)
      @editor.toolbar.wrapper.css(@cssStatus.toolbar.wrapper)
      @editor.body.css(@cssStatus.body)

    #全屏
    doFullScreen: ->
      #外部simditor
      @editor.el.css('position', 'fixed')
        .css('left', "9px")
        .css('right', "9px")
        .css('top', "9px")
        .css('bottom', "9px")
        .css('z-index',"9999")

      @editor.wrapper.css("height", "100%")

      @editor.toolbar.wrapper
        .css('width', "100%")

      toolbarHeight =  @editor.toolbar.wrapper.height()
      wrapperHeight = @editor.wrapper.height()
      @editor.body
        .css("maxHeight", wrapperHeight-toolbarHeight - 70 + "px")
        .css("overflow", "auto")

    command: ->
      #如果已经处于全屏状态
      if @isExpand
        @setIcon('expand')
        @resetStatus()
        @isExpand = false
        return

      @setIcon('compress')
      @saveStatus()
      @isExpand = true
      @doFullScreen()

  Simditor.Toolbar.addButton(FullScreenButton)
)