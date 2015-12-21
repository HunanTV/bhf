#Comment
##创建
在指定的issue下，创建comment

* URL：`project/:project_id/issue/:issue_id(\\d+)/comment`
* Verb: `POST`
* Data：

		{
			//评论的内容
			"content": "对issue的评论",
		}


##查询
查询某个issue下的所有评论

* URL：`project/:project_id/issue/:issue_id(\\d+)/comment`
* Verb: `GET`
* Data：所有字段都支持等试查询，请参考**Project - 查询**一节
* Retuns：

		{
		  "items": [
            {
              "id": 1,
              "project_id": 1,
              "creator": 0,
              "content": "测试",
              "timestamp": null,
              "issue_id": 1,
              "realname": null
            },
            {
              "id": 2,
              "project_id": 1,
              "creator": 0,
              "content": "测试",
              "timestamp": null,
              "issue_id": 1,
              "realname": null
            }
		  ],
		  "pagination": {
		    "page_index": 1,
		    "page_size": 10
		  }
		}

##更新
不支持对comment的更新


##删除

* URL：`project/:project_id/issue/:issue_id(\\d+)/comment/:id(\\d+)`
* Verb: `DELETE`