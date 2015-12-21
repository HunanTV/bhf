##项目讨论

### 讨论查询

#### 多条记录查询

说明： 一条讨论实际上也是一条issue 即任务。因此在下面的discussion数据中包含了一些是issue的属性

* URL: `project/:project_id(\\d+)/discussion`
* Verb: `GET` 
* Data: 


```js

Demo:
    {
        "pageSize": 10,
        "pageNumber"： 1
    }
    
Details：
  	"pageSize": 
  		Desc：分页数据每页数据条数   DataType: integer    [optional]   Default：10
    "pageNumber"：
    	Desc：要获取分页数据第几页面数   DataType: integer    [optional]   Default：1
```

* Returns

```js

Demo:
{
  "items": [
    {
      "id": 651,
      "title": "silky 文件结构探讨",
      "content": "<p>目前的文件结构，我觉得有点不太理想</p>",
      "tag": "project",
      "owner": null,
      "creator": 2,
      "status": "new",
      "timestamp": 1401176078335,
      "finish_time": null,
      "project_id": 2,
      "plan_finish_time": null,
      "priority": 3,
      "always_top": 1,
      "realname": "AAAA",
      "comment_count": 4
    },
    {
      "id": 712,
      "title": "增加一个normal环境，避免需要写两套数据",
      "content": null,
      "tag": "需求",
      "owner": 7,
      "creator": 7,
      "status": "done",
      "timestamp": 1401753806654,
      "finish_time": 1401869074052,
      "project_id": 2,
      "plan_finish_time": null,
      "priority": 3,
      "always_top": 0,
      "realname": "BBBB",
      "comment_count": 9
    }
  ],
  "pagination": {
    "pageSize": 6,
    "offset": 0,
    "limit": 6,
    "pageIndex": 1,
    "recordCount": 2,
    "pageCount": 1
  }
}

Details:
    "items": Desc: 返回的数据结果存储在此字段 DataType: Array
        "id":
            Desc: 讨论id   DataType: integer
        "title":
            Desc: 讨论标题  DataType: String
        "content":
            Desc: 讨论主体内容  DataType: String   Extra: 该字符串是一个html字符串，包含了html标签等
        "tag":
            Desc: 讨论的类型    DataType： String  Extra: 该值目前有三个： "bug", "需求"，"project" 分别表示讨论类型是： bug, 需求, 未指定(纯讨论)
        "owner":
            Desc: 该条讨论转成需求或者bug时，完成此条任务的队员的id    DataType: integer or null    Extra: 为null时 表示为纯粹的讨论
        "creator":
            Desc: 该条讨论的创建者  DataType: integer
        "status":
            Desc: 该条讨论转成具体类别（需求或bug）后的状态     DataType: String    Extra:
状态包括： "new", "undone", "done", "doing", "pause" 分别表示： 新任务, 未完成任务, 已完成任务, 正在处理中的任务, 已暂停任务
        "timestamp":
            Desc: 该条讨论创建的时间戳  DataType: integer
        "finish_time":
            Desc: 该条任务完成的时间戳  DataType: integer
        "plan_finish_time":
            Desc: 该条任务计划完成的时间戳  DataType: integer
        "project_id":
            Desc: 该条讨论所属的项目id
        "priority":
            Desc: 该条任务的紧急程度    DataType: integer   Extra: 分为5个等级， 1,2,3,4,5 紧急程度从高到低，1最高，5最低，3普通   Default: 3
        "always_top":
            Desc: 该条讨论是否置顶  DataType: integer   Extra: 1 为置顶 0为不置顶。 Default: 0
        "realname":
            Desc: 该条讨论创建人名称    DataType: String
        "comment_count"
            Desc: 该条讨论有多少条回复
    
    "pagination": 分页信息。具体参考分页信息部分
```

#### 单条讨论查询

* URL: `project/:project_id(\\d+)/issue/:discussion_id`
* Verb: `GET` 
* Data: 可忽略

* Returns

```js
Demo：
{
  "id": 1096,
  "title": "AV",
  "content": "<p>ASD</p>",
  "tag": "project",
  "owner": null,
  "creator": 10,
  "status": "new",
  "timestamp": 1405476522100,
  "finish_time": null,
  "project_id": 14,
  "plan_finish_time": null,
  "priority": 3,
  "always_top": 0
}

Details：
    字段详细同上文
    
    
Extra：
    获取该条讨论的回复，请见Comment 讨论回复部分
```


------

### 讨论创建

* URL: `project/:project_id(\\d+)/issue`
* Verb: `POST` 
* Data: 

```js

Demo：
    {
        "content": "<p>hello new Discussion !</p>"
        "status": "new"
        "tag": "project"
        "title": "这是标题"
        "always_top": 1
    }


Details:
    "content":
        Desc: "讨论的主体内容"  DataType: String    [needed]
    "status":
        Desc: "讨论状态"    DataType: String    [optional]  Default: 'new'
    "title":
        Desc: "讨论标题"    DataType: String    [needed]
    "tag":
        Desc: "讨论类型"    DataType: String [optional]     Default: '需求'     Extra:如果不指定为默认值，请设置它的值为 'project'
    'always_top':
        Desc: "是否置顶"    DataType: integer [optional]    Default: 0
```

------

### 讨论修改
#### 普通字段修改
* URL: `project/:project_id(\\d+)/issue/:discussion_id`
* Verb: `PUT` 
* Data: 需要修改的字段和对应的值

```js
可修改过的字段：
    "title", "content", "always_top"

Demo_0:
    {"title": "ABC"}  将title修改为ABC

Demo_1:
    {"title": "ABC", "always_top": true} 将title修改为ABC,并且置顶
    ....

Details
    具体字段请见上文
```

#### tag修改
* URL: `project/:project_id(\\d+)/issue/:discussion_id/tag`
* Verb: `PUT` 
* Data:

```js

Demo
    {"tag": "bug"}

Details
    "tag"
        Desc: 讨论的标签    DataType: String    Extra: 通常为"bug", "需求", "project"
```

------

### 讨论删除

* URL: `project/:project_id(\\d+)/issue/:discussion_id/status`
* Verb: `PUT` 
* Data: `{"status":"trash"}`

```js
Demo
    {"status":"trash"}

Details
    将该条讨论的的状态修改为trash,即可删除该条讨论   
```