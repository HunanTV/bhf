# 命名约定

* 文件名以短划线连接多个单词用，如`project-haeder.coffee`
* 变量采用驼峰式命名，如`fileName`
* jQuery对象以$开头，如`$this`
* css的class字母需要大写，如ClassName
* require引用的对象以_开头，如 `define(['restful'], function(_restful){})`
* jquery插件文件名以`jquery.honey.plugin-name.js`命名，如`jquery.honey.pagination.js`
* jquery插件名称则以`pluginName`的方式，如文件名为：`jquery.honey.plugin-name.js`，插件名为：pluginName，调用方式为：`$(expr).pluginName()`
* angular的service以ServiceName的方式命名，如果是缩写，则全部为大写，如API
* css样式命名采用class-name的方式
* directive在html调用的时候采用`directive-name`的方式，在定义的时候使用`directiveName`的方式
* 工具类的函数放到utils.coffee
* angular中的命名以on+event+name的方式，如`onClickCancel`表示要点击一个cancel的按钮，`onFocusTitle`，表示焦点进入一个名为title的input

# HTML5/CSS3
* 本项目基于HTML5/CSS3，不用考虑兼容旧版本浏览器
* 请使用语义化HTML，请使用有意义的class命名
* 如果引用了第三方模块，并需要修改第三方模块的css，请不要修改原来的css，而是在hack.less中进行覆盖
* 

# 文件组织

* 第三方代码放在js/vendor
* 较大型的第三方包直接放到根目录(一般不会有这个)
* 根据后端restful的模块，共分为assets/comment/member/issue/project等模块
* 每个模块下会有一个index文件，添加新的文件，需要在index.coffee中进行引用即可
* 对于简短的directive或者controller(不超过20行)，统一写对应模块的`<module>-controlers`或者`<module>-directives`下
* 对于较长的controller和directive，controller以文件名+Controller，directive以文件名+Directive

# 模板

* 模板放在views下面，与js的模块一一对应
* 如果模板的内容较多（超过20行），则独立出来为一个文件
* 内容较少的模板放到对应模块的all.html，使用textarea包起来即可，这样可以解决小的模块文件过于分散的问题。
* 模板中textarea的id命名方式采用`tmpl-<moduleName>-templateName`，如`tmpl-issue-list`表示issue模块下的list模板
* 需要使用的时候用extractTemplate获得模板的HTML，如`_utils.extractTemplate('#tmpl-issue-list', _tmplIssue)`

# 路由与API调用

* 使用严格模式，即use strict
* restful API调用需要引用API这个service，使用restful 动词调用即可，如`API.get(url, params).then(yourFunction)`，支持的动词包括get/post/put/delete，同时还支持`API.save(url, data)`的方式调用，此方法会判断是否包含有id，如果有id则调用API.put，否则调用API.post
* 路由根据restful的API，请参考后端的API接口文档

# 其它
* 除非特殊情况，不要在代码中使用callback，callback改用promise的解决方式，本项目中使用$q
* 推荐使用coffee，但这并不是必需的
* 插件优先，如果能基于jquery的插件，则尽量封装成jquery的插件，jquery插件要求同时支持amd
* 事件优先，angular的directive之间基于事件通信，各模块之间松散耦合，彼此不知道对方的存在
* 更多代码规范，请参考[Google JavaScript Style Guide](http://google-styleguide.googlecode.com/svn/trunk/javascriptguide.xml)
