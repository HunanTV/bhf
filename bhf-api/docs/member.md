#登录注册
用户相关，注册/登录/注销/获取用户资料(登录检测)

##检测登录
获取当前用户的信息，如果未登录，会返回401的状态码

* URL: `mine`
* Verb: `GET`
* Returns:

		{
			"realname": "李四",
			"username": "lishi",
			"email": "lishi@gmail.com"
		}


##登录

* URL: `mine`
* Verb: `PUT`
* Data:

		{
	      username: 'conis',
	      password: '123456'
	    }


##注册
* URL: `mine`
* Verb: `POST`
* Data:

		{
			realname: '张三',     //真实姓名
			username: 'conis',    //用户名
			password: '123456',     //密码
			email: 'email@gmail.com',    //用户邮件
			git: 'git@git.hunantv.com'  //用户的git帐号
		}

##注销
* URL: `mine`
* Verb: `DELETE`

#成员相关

##获取所有成员
* URL: `member`
* Verb: `GET`
* Returns:
返回所有的成员信息

		{
		  "items": [
		    {
		      "id": 1,
		      "username": "conis",
		      "email": "lishi@gmail.com",
		      "realname": "易晓峰",
		      "git": "wvv8oo@gmail.com"
		    },
		    {
		      "id": 2,
		      "username": "lxl",
		      "email": "lxlneo.g@gmail.com",
		      "realname": "李雪龙",
		      "git": "lxlneo.g@gmail.com"
		    }
		  ]
		}
