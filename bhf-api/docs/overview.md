#约定
1. api的地址为 `/api/[api 地址]`
2. api地址中，[]内为变量，:project_id表示占位符，如果出现?，则表示参数可选。例如：`project/:id(\\d+)?`，表示能接受`:project`与`project/19`两种方式的地址，后面的`(\\d+)`表示只接受数字形式的id
3. 对于服务器返回的数据，首先应该进行状态码检查，例如返回401，表示需要登录；返回406，则表示用户提供的数据不合法，像登录密码不正确，删除了不属于自己的数据都会出现这样的问题
4. 查询分页，对于列表类的API，都支持分页查询，允许附加参数`page_size`和`page_index`两个参数来获取指定数量的数据。**目前暂不支持此功能**
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