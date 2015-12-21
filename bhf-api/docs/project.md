#Project
##创建
* URL：`project`
* Verb: `POST`
* Data：

```js
Demo:
    {
      "title": "芒果网首页",
      "description": "芒果网的新版首页" 
      "gits":  ["http://github.com/xxx/xxx","http://github.com/xxx/xxx"]
    }

Details：
    "title": 
        Desc：项目标题   DataType: String    [needed] 
    "description":
        Desc：项目的详细描述    DataType: String  [optional]
    "gits":
        Desc：仓库地址（绑定commim）   DataType: Array   [optional]  Extra:  推荐根据repos.split('\n')获取 
    
```

* Returns

```js
Demo：
  {
      "id": 22
  }

Details:
    "id": 
        Desc：项目id   DataType: integer
```

##批量查询  (暂时仅支持分页查询)
* URL：`project`
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
      "id": 4,
      "title": "BHF",
      "description": "项目管理工具，包括API和UI两个repos",
      "gits": ["git@git.hunantv.com:conis/bhf.git", "git@git.hunantv.com:conis/bhf-api.git", "git@git.hunantv.com:huyinhuan/bhf.git"],
      "creator": 7,
      "timestamp": 1400563068267,
      "status": null,
      "options": "{\"extra_functions\":[{\"func_name\":\"XXX\",\"func_url\":\"http://localhost:8010/template/index-number.html\",\"right\":[]},{\"func_url\":\"http://localhost:8010/template/index-milepost.html\",\"func_name\":\"AAA\",\"right\":[]}]}",
      "flag": 0
    },
    {
      "id": 15,
      "title": "芒果TV数据监控平台",
      "description": "主要是前端的一些数据，便于开发以及产品进行参考",
      "gits": null,
      "creator": 2,
      "timestamp": 1400563068267,
      "status": null,
      "options": null,
      "flag": 0
    }
  ],
  "pagination": {
    "pageSize": 11,
    "offset": 0,
    "limit": 11,
    "pageIndex": 1,
    "recordCount": 4,
    "pageCount": 1
  }
}

Details:
"items":    Desc： 查询数据结果集    DataType： Array
    "id": 
        Desc: 项目id  DataType： integer
    "title": 
        Desc：项目标题   DataType: String
    "description":
        Desc：项目的详细描述    DataType: String  or  null
    "gits":
        Desc：仓库地址（绑定commim）   DataType: Array  or null
    "creator":
        Desc: 创建者id  DataType： integer
    "timestamp":
        Desc: 项目创建时间戳（精确毫秒）。  DataType： integer
    "status":
        Desc: 项目状态（保留字段）。    DataType: String or null   Extra: 如果该字段不为null，那么状态可能为 "new" 或者 "trash"
    "options":
        Desc: 扩展设置.     DataType: String or null    Extra: 该字段保存一些扩展设置。需要通过JSON.parse解析成JSON 对象
    "flag": 
        Desc: 保留字段 DataType:  integer     Extra: １为特殊项目所有人可见 0为普通项目，根据权限分配可见

"pagination":   Desc: 分页信息  DataType: JSON-Object
    "pageSize": 
      Desc：分页数据每页数据条数   DataType: integer  Extra: 和查询时的pageSize一致
    "offset":
        Desc: 可以忽略  DataType: integer
    "limit":
        Desc: 可以忽略  DataType: integer
    "pageIndex":
        Desc: 当前页面数    DataType: integer
    "recordCount":
        Desc: 查询数据总条数    DataType: integer
    "pageCount":
        Desc: 查询数据分页总数目    DataType: integer
```

##查询项目（单个）
* URL: `project/:id(\\d+)`
* Verb: `GET`
* Data: 可忽略
* Returns

```js

Demo:
{
  "id": 4,
  "title": "BHF",
  "description": "项目管理工具，包括API和UI两个repos",
  "gits": ["git@git.hunantv.com:conis/bhf.git"],
  "creator": 7,
  "timestamp": 1400563068267,
  "status": null,
  "options": "",
  "flag": 0,
  "members": [
    {
      "username": "bbb",
      "member_id": 5,
      "role": "d"
    },
    {
      "username": "aaa",
      "member_id": 7,
      "role": "l"
    }
  ],
  "role": "d"
}

Details:
    "id", "title", "description", "gits", "creator", "timestamp", "status", "options", "flag"
    以上字段上文已做出说明不再赘述。
    "members": Desc: 该项目的团队成员  DataTyoe: Array
        "username": 
            Desc: 成员名称  DataType: String
        "member_id":
            Desc: 成员Id    DataType: integer
        "role":
            Desc: 成员在该项目中的角色  DataType: String    Extra: 'd'- 开发， 't'- 测试， 'p'-产品, 'l'-Leader
    "role":
        Desc: 当前登陆用户在该项目的角色    DataType:String     Extra:同上
```

##更新
* URL：`project/:id(\\d+)`
* Verb: `PUT`
* Data:  将要更改的字段及对应的值

```js
可修改的字段："title"， "description"， "gits"， "options"
具体字段详细请见上文

Demo
    {title:"A"}  修改title
    {title:"A", gits:["git.xxx.com/xx/xx"]} 修改title和gits仓库
```

##删除
* URL：`project/:id(\\d+)`
* Verb: `DELETE`

##更改状态
* URL：`project/:project_id(\\d+)/status`
* Verb: `PUT`
* Data:

```js
Demo:
  {
    status: "trash"
  }
  
Detail:
    "status":
        Desc:   项目状态    DataType: String    Extra: 更改为trash则表示该项目废弃。查询时不会获取该项目 
```