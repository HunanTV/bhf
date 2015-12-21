日期控件API
====
使用方式
---
支持date datetime  time 三种模式

date
---
html:　属性 ``` datetime－picker  ``` 　标识　directive
```html 
<div class="finish-date" 
     datetime－picker 
     data-name="plan_finish_time"
     data-type="date|datetime|time"
     data-formart='yyyy-MM-dd'
 >
         <i class="icon small cell"></i>
</div>
```
在关闭日期选择框时发送``` datetime:change ``` 事件  
```javascript
scope.$emit 'datetime:change', name,date
```
可以通过name 来区分处理

