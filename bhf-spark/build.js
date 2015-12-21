({
    appDir: './',
    baseUrl: 'js',
    optimizeCss: "none",
    stubModules : ['text'],
//    mainConfigFile: "main.js",
    optimize: "none",
    removeCombined: true,
    paths: {
        ng: 'vendor/angular',
        v: 'vendor',
        jquery: 'vendor/jquery',
        _: 'vendor/lodash',
        t: 'vendor/require.text',
        moment: 'vendor/moment',
        angularRoute: 'vendor/angular-route',
        echarts: 'vendor/echarts',
        utils: 'utils',
        pkg: '../package',
        marked: 'vendor/marked',
        'simditor-marked': 'vendor/simditor-marked'
    },
    shim: {
        'simditor-marked': ['marked', 'v/simditor'],
        'notify': ['jquery', 'v/jquery.noty'],
        ng: {
            exports: 'angular'
        },
        angularRoute: {
            deps: ['ng', 'v/angular-locale_zh-cn']
        },
        'v/jquery.transit': ['jquery', '_'],
        app: ['ng', 'jquery'],
        'v/jquery.modal': 'jquery'
    },
    dir: '../www-built',
    modules: [
        {
            name: 'main',
            fileExclusionRegExp: /^v\//i
//            exclude: [
////                "v/charm",
//                "t",
//                "angularRoute",
//                "_",
//                "marked",
//                "ng",
//                "jquery",
//                "echarts",
//                "moment",
//                "notify",
//                "v/jquery.modal",
//                "pkg/colorbox/jquery.colorbox",
//                "pkg/datetime/datetimepicker",
//                "pkg/webuploader/webuploader.html5only",
//                "v/ui-router",
//                "pkg/jquery.autocomplete/jquery.autocomplete",
//                "v/FileAPI.html5",
//                "pkg/highlight/highlight.pack",
//                "plugin/jquery.honey.simple-tab",
//                "v/keyboard",
//                "v/store2",
//                "v/simditor",
//                "simditor-mention",
//                "simditor-marked"
//            ]
        }
    ]
})