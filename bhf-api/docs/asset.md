#Asset
##创建
在指定的项目下上传一个素材

* URL：`project/:project_id(\\d+)/asset`
* Verb: `POST`
* Data：

##查看
查看指定项目下的所有素材

* URL：`project/:project_id(\\d+)/asset`
* Verb: `GET`
* Returns:

		{
		  "items": [
		    {
		      "id": 1,
		      "project_id": 13,
		      "file_name": "8e8c1021-6f6b-4ac8-b740-2d6669465ec8.png",
		      "file_type": "image/png",
		      "file_size": 448748,
		      "description": null,
		      "original_name": "Screen Shot 2014-03-20 at 9.22.05 am.png",
		      "url": "/assets/13/8e8c1021-6f6b-4ac8-b740-2d6669465ec8.png"
		    }
		  ],
		  "pagination": {
		    "page_index": 1,
		    "page_size": 10
		  }
		}

##查看某个文件
以文件的方式查看素材，注意，此路径不包含`/api/`这个目录
通常这个地址是由`project/:project_id(\\d+)/asset`列表中的`items[0].url`获得的

* URL：`/project/:project_id(\\d+)/assets/:filename`
* Verb: `GET`
* Data：


##更新
不支持更新

##删除
不支持删除