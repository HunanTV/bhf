#Commit

##接收Git Commit

* URL: `commit`
* Verb: `POST`
* Data：
数据格式参考GitLab提供的数据格式，略。注意需要用户库中的git邮件地址要与commit的邮件地址匹配，project的git地址，也需要与git库的url匹配，否则无法识别到正确的的项目与人


##commit message的标签
在提交commit的时候，可以通过在message中添加指定的标签，触发相应的操作。

1. `\#+数字id`，表示将commit关联到具体的issue，如`#12`表示将此commit关联到id为12的issue

2. `\#done`（也包括`#ok`）表示完成某个issue，这个必需和#id组合使用，如#12#done，表示将关联id为12的issue，同时完成此issue

3. `\#0`（也包括`#create`、`#new`）表示创建一个新的issue，并将此commit关联到新的issue，此命令可以组合状态。如`#0#doing`，表示创建一个issue,同时将此issue的状态置为doing

4. `@tag`，表示给新建的issue打上标签，如`#0@bug#done`，表示新建一个issue，tag为bug，状态为done，注意`@tag`后面一定要有空格，`@bug修改了xx问题`这种是不会被正确识别的

##读取project下的commit
获取某个Project下的commit Top N，如果没有指定Limit，则获取10条

* URL：`project/:project_id(\\d+)/commit`
* Verb: `GET`
* Data：

		{
			"limit": 10
		}
* Returns

		{
		  "items": [
		    {
		      "id": 133,
		      "project_id": 4,
		      "issue_id": 80,
		      "creator": 1,
		      "message": "  给discussion增加comment_count的字段",
		      "sha": "4437c0adf999328c22b874dbd5379f64ba9676ba",
		      "addition": null,
		      "deletion": null,
		      "timestamp": 1400224476882,
		      "url": "http://git.hunantv.com/conis/bhf-api/commit/4437c0adf999328c22b874dbd5379f64ba9676ba",
		      "email": "wvv8oo@gmail.com",
		      "realname": "易晓峰"
		    }
		  ],
		  "pagination": {
		    "limit": "2",
		    "offset": 0,
		    "count": 25
		  }
		}

##读取issue下的commit
获取某个Issue下的commit Top N，如果没有指定Limit，则获取10条

* URL：`project/:project_id/issue/:issue_id(\\d+)/commit`
* Verb: `GET`
* Data：

		{
			//指定最大获取的数量
			"limit": 20,
		}

* Returns

		{
		  "items": [
		    {
		      "id": 72,
		      "project_id": 4,
		      "issue_id": 50,
		      "creator": 1,
		      "message": "增加支持#零作为创建标签 #50",
		      "sha": "01abe0d4187b67d7f088ae59fb3445d5324b34df",
		      "addition": null,
		      "deletion": null,
		      "timestamp": 1400051503163,
		      "url": null,
		      "email": null,
		      "realname": "易晓峰"
		    }
		  ],
		  "pagination": {
		    "limit": "9999",
		    "offset": 0,
		    "count": 2
		  }
		}
