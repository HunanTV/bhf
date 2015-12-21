//issue模块必需在project模块后调用
describe('测试issue模块', function(){
    var generalURL

    it('添加issue', function(done){
        var data = {
            "title": USERNAME + "的issue",
            "content": "详细的描述",
            "tag": "需求",
            "owner": 1,
            "status": "doing"
        }

        //必需在it下，因为在describe下不会被done中断
        generalURL = 'project/' + PROJECTID + '/issue'

        doAction(generalURL, 'POST', data, function(status, content){
            expect(ISSUEID = content.id).to.be.a('number')
            done()
        })
    })

    it('获取issue', function(done){
        var url = generalURL + '/' + ISSUEID
        doAction(url, 'GET', null, function(status, content){
            expect(content).to.have.keys('title', 'id')
            expect(content.id).to.be(ISSUEID)
            done()
        })
    })


    it('修改issue', function(done){
        var url = generalURL + '/' + ISSUEID
        var data = {title: '修改后的issue标题'}
        doAction(url, 'PUT', data, function(){
            //获取刚刚修改后的issue
            doAction(url, 'GET', null, function(status, content){
                expect(content.title).to.be(data.title)
                done()
            })
        })
    })

    it('查询一个项目下的所有issue', function(done){
        doAction(generalURL, 'GET', null, function(status, content){
            expect(content.items.length).to.greaterThan(0)
            done()
        })
    })

    it('更改issue的状态', function(done){
        var data = {
            status: 'doing'
        }

        var url = generalURL + '/' + ISSUEID + '/status'
        doAction(url, 'PUT', data, function(){
            doAction(generalURL + '/' + ISSUEID, 'GET', null, function(status, content){
                expect(content.status).to.be(data.status)
                done()
            })
        })
    })

    it('修改issue的优先级', function(done){
        var data = {
            priority: 5
        }

        var url = generalURL + '/' + ISSUEID + '/change-priority'
        doAction(url, 'PUT', data, function(){
            doAction(generalURL + '/' + ISSUEID, 'GET', null, function(status, content){
                expect(content.priority).to.be(data.priority)
                done()
            })
        })
    })

    /*
     //并不包含实际文件的上传，asset表也不会有相同的文件记录存在
     it('测试更新assets', function(done){
     var url = generalURL + '/' + ISSUEID
     var data = {assets: [1,2,3]}
     var newData = {assets: [4, 5, 6]}

     async.series([
     function(callback){
     //第一次清除掉asset
     doAction(url, 'PUT', {assets: null}, function(){callback(null)})
     },function(callback){
     //第一次增加assets
     doAction(url, 'PUT', data, function(){callback(null)})
     }, function(callback){
     //第二次批量增加assets
     doAction(url, 'PUT', newData, function(){callback(null)})
     }, function(callback){
     //检查assets的总数
     doAction('issue/' + ISSUEID + '/asset', 'GET', null, function(status, content){
     expect(content.items.length).to.be(newData.assets.length)
     done()
     })
     }])
     })
     */
})