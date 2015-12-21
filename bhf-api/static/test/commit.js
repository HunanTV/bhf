//用于测试提交commit相关
describe('测试commit模块', function() {
    return;
    it('模拟git commit', function(done){
        var data = {
            "before": "7ee36e1c096c4b721ec564f16edd97bdb6c55b22",
            "after": "393fa0a29ec5839319c79875073d6014b88d1826",
            "ref": "refs/heads/master",
            "user_id": 14,
            "user_name": "易晓峰",
            "project_id": 80,
            "repository": {
                "name": "BHF-API",
                "url": "git@git.hunantv.com:conis/bhf-api.git",
                "description": "BHF的API端",
                "homepage": "http://git.hunantv.com/conis/bhf-api"
            },
            "commits": [
                {
                    "id": "9974e84986cda6c35c464f76866462ccfe3caab4",
                    "message": "test",
                    "timestamp": "2014-05-08T17:08:00+08:00",
                    "url": "http://git.hunantv.com/conis/bhf-api/commit/9974e84986cda6c35c464f76866462ccfe3caab4",
                    "author": {
                        "name": "李雪龙",
                        "email": "lxlneo.g@gmail.com"
                    }
                },
                {
                    "id": "507f9c2e621c81529cf77d2919a0bd09e90b35a5",
                    "message": "test update",
                    "timestamp": "2014-05-08T17:08:38+08:00",
                    "url": "http://git.hunantv.com/conis/bhf-api/commit/507f9c2e621c81529cf77d2919a0bd09e90b35a5",
                    "author": {
                        "name": "李雪龙",
                        "email": "lxlneo.g@gmail.com"
                    }
                },
                {
                    "id": "fc177be57279359eaca628014ab977d1949927f3",
                    "message": "test again",
                    "timestamp": "2014-05-08T17:13:29+08:00",
                    "url": "http://git.hunantv.com/conis/bhf-api/commit/fc177be57279359eaca628014ab977d1949927f3",
                    "author": {
                        "name": "李雪龙",
                        "email": "lxlneo.g@gmail.com"
                    }
                },
                {
                    "id": "91eae7a29d7d11917036b6bf9c9c899a0472c747",
                    "message": "#done #2 test2",
                    "timestamp": "2014-05-08T17:15:36+08:00",
                    "url": "http://git.hunantv.com/conis/bhf-api/commit/91eae7a29d7d11917036b6bf9c9c899a0472c747",
                    "author": {
                        "name": "李雪龙",
                        "email": "lxlneo.g@gmail.com"
                    }
                },
                {
                    "id": "3358d1fb1a0188cd059a28ccc6e10f48b5797fa1",
                    "message": "#done #1 add test3",
                    "timestamp": "2014-05-08T17:17:19+08:00",
                    "url": "http://git.hunantv.com/conis/bhf-api/commit/3358d1fb1a0188cd059a28ccc6e10f48b5797fa1",
                    "author": {
                        "name": "李雪龙",
                        "email": "lxlneo.g@gmail.com"
                    }
                },
                {
                    "id": "393fa0a29ec5839319c79875073d6014b88d1826",
                    "message": " Merge branch 'testbylxl' into 'master'\n\nTestbylxl\n\ntest by lxl",
                    "timestamp": "2014-05-08T17:25:59+08:00",
                    "url": "http://git.hunantv.com/conis/bhf-api/commit/393fa0a29ec5839319c79875073d6014b88d1826",
                    "author": {
                        "name": "易晓峰",
                        "email": "conis.yi@gmail.com"
                    }
                }
            ],
            "total_commits_count": 6
        }
        doAction('git/commit', 'POST', data, function(status){
            done()
        })
    })
})