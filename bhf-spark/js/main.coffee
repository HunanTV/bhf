
require.config
  urlArgs: "v=#{document.querySelector('head>script[data-cachekey]').getAttribute("data-cachekey")}"
  baseUrl: '/js'
  paths:
    ng: 'vendor/angular'
    v: 'vendor'
    jquery: 'vendor/jquery'
    _: 'vendor/lodash'
    t: 'vendor/require.text'
    moment: 'vendor/moment'
    angularRoute: 'vendor/angular-route'
    echarts: 'vendor/echarts'
    utils: 'utils'
    pkg:'/package'
    marked: 'vendor/marked'
    simditor:'vendor/simditor'
    'simditor-mention': 'vendor/simditor-mention'
    'simditor-marked': 'vendor/simditor-marked'
    'simditor-fullscreen': 'vendor/simditor-fullscreen'
    'simple-module': 'vendor/simditor-module'
    'simple-uploader': 'vendor/simditor-uploader'
    'simple-hotkeys': 'vendor/simditor-hotkeys'
    highlight: '/package/highlight/highlight.pack'
    datepicker: '/package/datetime/datetimepicker'
  shim:
    'v/jquery.noty': 'jquery'
    'simditor': ['vendor/simditor', 'vendor/simditor-module', 'vendor/simditor-marked', 'vendor/simditor-fullscreen', 'vendor/simditor-hotkeys','vendor/simditor-uploader','vendor/simditor-mention']
    'notify': ['jquery', 'v/jquery.noty']
    ng: exports : 'angular'
    angularRoute: deps: ['ng', 'v/angular-locale_zh-cn']
    'v/jquery.transit': ['jquery', '_']
    app: ['ng', 'jquery', 'highlight']
    'v/jquery.modal': 'jquery'

window.name = "NG_DEFER_BOOTSTRAP!";

require [
  "ng"
  "app"
  "routes"
  'notify'
  'jquery'
], (_ng, _app, routes, _notify) ->

  (->
    timer = null
    $window = $(window).resize(->
      timer = setTimeout(->
        $window.trigger "onResizeEx"
      , 500)
  )
  )()

  #检测不支持的浏览器
  (->
#暂不检测浏览器，避免给用户造成干扰
#    ua = window.navigator.userAgent
#    if /safari|msie/i.test(ua) and not /chrome/i.test(ua)
#    console.log browser
#    if not (browser.firefox or browser.chrome or browser.webkit)
#      $('#loading').fadeOut()
#      _notify.error '警告：您的浏览器可能不受支持，建议使用Safari/Firefox/Chrome/Opera/IE 11'
#      #return

    _ng.element().ready ->
      _ng.resumeBootstrap [_app.name]
      $('#loading').fadeOut()
  )()


