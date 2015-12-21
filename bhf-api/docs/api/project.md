#约定
1. api的地址为 `/api/[api 地址]`
2. api地址中，[]内为变量，:project_id表示占位符，如果出现?，则表示参数可选。例如：`project/:id(\\d+)?`，表示能接受`:project`与`project/19`两种方式的地址，后面的`(\\d+)`表示只接受数字形式的id
3. 对于服务器返回的数据，首先应该进行状态码检查，例如返回401，表示需要登录；返回406，则表示用户提供的数据不合法，像登录密码不正确，删除了不属于自己的数据都会出现这样的问题 
5. `src/static/test.js`包含部分测试代码，供参考
6. 服务器返回的如下状态码(HTTP Status Code)
  * 200 正常情况
  * 401 未经授权，用户需要重新登录
  * 406 用户提交的数据错误，会返回具体的错误原因
  * 404 没有这个资源
  * 500 服务器错误

#环境变量
请参考Node.js的环境变量，参考示例：`PORT=3001 BRANDNEW=yes node-dev app.coffee`

1. `NODE_ENV` 当前运行环境，在产品环境下需要指定`NODE_ENV=production`
2. `ASSETS`：指定素材库的存储目录，环境变量的优先级比config.json优先级高
3. `DBPATH`：指定sqlite的存储文件路径，注意，**需要指定包含文件名在内的全路径**。例如：`DBPATH=/var/www/BHF-API/db.sqlite`
4. `BRANDNEW`：取值为`yes`，在app被启动时，创建全新的环境，一般用于执行测试用例。**警告：这将会删除旧的数据库**
5. `PORT`：指定运行的端口，默认端口为`14318`

#API文档
##约定
1. [needed] 必填字段； [optional] 可选填字段
2. DataType 数据类型
3. Desc 字段描述
5. Default 默认值 仅当[optional]存在时使用
4. Extra 额外说明说明
5. Demo: 举例
6. Details: 字段详细解释
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