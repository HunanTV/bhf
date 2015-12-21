#Issue
##创建
在指定的project下创建issue

* URL：`project/:project_id(\\d+)/issue`
* Verb: `POST`
* Data：

		{
			//标题
			"title": "首页搜索栏要实时展示",
			//内容
			"content": "详细的描述",
			//标签，也就是分类
			"tag": "需求",
			//责任人
			"owner": "兰斌",
			//状态
			"status": "进行中",
			//关联的asset列表
			"assets": [1, 2, 3, 4],
			//时间
			"timestamp": "2014-03-20 10:10:10"
		}



##查询
查询某个项目下的所有issue，如果id参数被赋与，则获取指定id的issue

* URL：`project/:project_id(\\d+)/issue/(\\d+)?`
* Verb: `GET`
* Data：

		{
			//如果指定为undone，则查未完成的(new/doing/pause)，否则查指定状态
			"status": "undone",
			//指定标签
			"tag": "bug",
			//开始时间，注意转成Number
			"beginTime": Number(new Date())
		}
* Retuns：

		{
		  "items": [
		    {
		      "id": 3,
		      "title": "title",
		      "content": "content",
		      "tag": null,
		      "owner": null,
		      "status": "新建",
		      "timestamp": null,
		      "project_id": 13
		    },
		    {
		      "id": 9,
		      "title": "title",
		      "content": "content",
		      "tag": null,
		      "owner": null,
		      "status": "新建",
		      "timestamp": null,
		      "project_id": 13
		    }
		  ],
		  "pagination": {
		    "page_index": 1,
		    "page_size": 10
		  }
		}

查询某个成员的未完成的issue
* URL: `myself`
* Verb: `PUT`
* Data:

        {
            my:true //如果值为true 则查找当前用户的.如果值为member_id则查对应成员未完成的issue
        }
*Return:

        {
            {
              "items": [
                {
                  "id": "id",
                  "title": "title",
                  "content": content,
                  "tag": "tag",
                  "owner": owner,
                  "creator": creator,
                  "status": "status",
                  "timestamp": 1401176307426,
                  "finish_time": null,
                  "project_id": project_id,
                  "plan_finish_time": plan_finish_time,
                  "owner_name": "owner_name",
                  "creator_name": "creator_name",
                  "project_name": "project_name"
                }
              ],
              "pagination": {
                "pageSize": 9999,
                "offset": 0,
                "limit": 9999,
                "pageIndex": 1,
                "count": count,
                "recordCount": recordCount,
                "pageCount": 1
              }
            }
        }

##更新
更新issue

* URL：`project/:project_id(\\d+)/issue/(\\d+)`
* Verb: `PUT`
* Data: 请参考**Issue - 新建**一节中的Data部分

##删除

* URL：`project/:project_id(\\d+)/issue/(\\d+)`
* Verb: `DELETE`


##讨论

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

##查看项目的讨论
获取一个项目下所有的讨论

* URL: `project/:project_id(\\d+)/discussion`
* Verb: `GET`
* Data:

		{
			limit: 10,
			offset: 10
		}

* Returns

		{
		  "items": [
		    {
		      "id": 68,
		      "title": "讨论一下commit的指令",
		      "content": "<p>&nbsp; 1. #+数字id，表示将commit关联到具体的issue</p>",
		      "tag": "project",
		      "owner": null,
		      "creator": 0,
		      "status": "new",
		      "timestamp": 1400060911827,
		      "finish_time": null,
		      "project_id": 4,
		      "plan_finish_time": null,
		      "realname": null,
		      "comment_count": 1
		    }
		  ],
		  "pagination": {
		    "limit": "6",
		    "offset": 0,
		    "count": 1
		  }
		}

