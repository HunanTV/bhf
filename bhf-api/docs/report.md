#Report
##查询issue
按时间段，查义issue的详细报表

* URL：`report/issue`
* Data:

		{
			"end_time": 1400397728000,
			"end_time": 1399879328000
		}

* Verb: `GET`
* Returns：

返回已经分配(assigned)和未分配(unassigned)两个键值，assigned返回一个数组，包含用户与该用户相关的详细issue。unassigned返回同期无法关联到任何用户的issue。

		{
		  "assigned": [
		    {
		      "member": {
		        "id": 1,
		        "username": "conis",
		        "email": "lishi@gmail.com",
		        "password": "e10adc3949ba59abbe56e057f20f883e",
		        "realname": "易晓峰",
		        "role": "user",
		        "git": "wvv8oo@gmail.com"
		      },
		      "issue": [
		        {
		          "id": 1,
		          "title": "修改后的issue标题",
		          "content": "详细的描述",
		          "tag": "需求",
		          "owner": 1,
		          "creator": 1,
		          "status": "new",
		          "timestamp": 1400032408446,
		          "finish_time": null,
		          "project_id": 2,
		          "plan_finish_time": null,
		          "project_name": null
		        }
		      ]
		    }
		    //...
		  ],
		  "unassigned": [
		    {
		      "id": 4,
		      "title": "观看记录本地存储跨域名不能共享",
		      "content": null,
		      "tag": "bug",
		      "owner": null,
		      "creator": 0,
		      "status": "new",
		      "timestamp": 1400032641932,
		      "finish_time": null,
		      "project_id": 3,
		      "plan_finish_time": null,
		      "project_name": "芒果TV"
		    }
		  ]
		}

按时间段，查某个成员的issue的详细报表

* URL：`report/myreport`
* Data:

		{
			"end_time": 1400397728000,
			"end_time": 1399879328000,
			"member_id":1 //如果该字段存在,则查该成员的issue ,如果不存在,则查登陆该系统的成员的issue
		}

* Verb: `GET`
* Returns：

返回已经分配(assigned)和未分配(unassigned)两个键值，assigned返回一个数组，包含用户与该用户相关的详细issue。unassigned返回同期无法关联到任何用户的issue。

		{
		  "assigned": [
		    {
		      "member": {
		        "id": 1,
		        "username": "conis",
		        "email": "lishi@gmail.com",
		        "password": "e10adc3949ba59abbe56e057f20f883e",
		        "realname": "易晓峰",
		        "role": "user",
		        "git": "wvv8oo@gmail.com"
		      },
		      "issue": [
		        {
		          "id": 1,
		          "title": "修改后的issue标题",
		          "content": "详细的描述",
		          "tag": "需求",
		          "owner": 1,
		          "creator": 1,
		          "status": "new",
		          "timestamp": 1400032408446,
		          "finish_time": null,
		          "project_id": 2,
		          "plan_finish_time": null,
		          "project_name": null
		        }
		      ]
		    }
		    //...
		  ],
		  "unassigned": [
		    {
		      "id": 4,
		      "title": "观看记录本地存储跨域名不能共享",
		      "content": null,
		      "tag": "bug",
		      "owner": null,
		      "creator": 0,
		      "status": "new",
		      "timestamp": 1400032641932,
		      "finish_time": null,
		      "project_id": 3,
		      "plan_finish_time": null,
		      "project_name": "芒果TV"
		    }
		  ]
		}