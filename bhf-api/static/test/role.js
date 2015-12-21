/*
    测试与权限相关的
 */

describe('测试角色与权限', function() {
    //组合权限测试
    function testGroup(){
        this.role = 'u'
        this.project_id = 0
        this.member_id = 0
        //检查结果
        this.result = {
            //创建项目
            createProject: false,
            //创建issue
            createIssue: false,
            //管理成员
            member: false
        }
    }

    testGroup.propertype = {
        //检查结果
        check: function(){

        },
        //登录
        sigin: function(){

        },
        //更改用户的权限
        changeRole: function(cb){
            var self = this
            var data = {account: 'admin', password: '888888'}
            //用管理员的帐号登录
            doAction('mine', 'PUT', data, function(){
                var url = 'project/' + self.project_id + '/member'
                var data = {member_id: self.member_id, role: self.role}
                doAction(url, 'PUT', data, cb)
            })
        }
    }

    var DATA = {
        //新建用户的帐号
        account: 'test' + Number(new Date()),
        //新建用户的id
        member_id: 0,
        //新建项目的id
        project_id: 0,
        //管理员的id
        root_id: 0
    }

    it('用管理员的身份登录', function(done){
        var data = {account: 'admin', password: '888888'}
        //管理员登录
        doAction('mine', 'PUT', data, function(status, content){
            expect(status).to.be(200)
            DATA.root_id = content.member_id
            done()
        })
    })

    it('添加测试用户', function(done){
        var data = {
            username: DATA.account,
            password: PASSWORD,
            email: EMAIL
        }

        //用新用户登录
        doAction('mine', 'POST', data, function (status, content, xhr) {
            DATA.member_id = content.id
            expect(content.id).to.be.a('number')
            done()
        })
    })

    it('创建测试项目', function(done){
        //创建一个项目，不添加任何用户
        var data = {
            status: "new",
            "title": "测试项目",
            "description": "项目的介绍",
            "start_date": NOW,
            "end_date": NOW,
            "members": [DATA.member_id]
        }

        doAction('project', 'POST', data, function(status, content){
            expect(content.id).to.be.a('number')
            DATA.project_id = content.id
            done()
        })
    })


    it('修改用户在项目中的权限 d -> l', function(done){
        var data = {
            role: 'l',
            member_id: DATA.member_id
        }
        var url = 'project/' + DATA.project_id + '/member'
        doAction(url, 'PUT', data, function(){
            doAction(url, 'GET', null, function(status, content, xhr){
                //查到用户，并检查此用户在项目中的权限是否已经被修改
                for(var i = 0; i < content.length; i ++){
                    var member = content[i]
                    if(member.username === DATA.account){
                        expect(member.role).to.be.eql(data.role)

                        //将用户的权限改回来
                        data.role = 'd'
                        doAction(url, 'PUT', data, function(){
                            done()
                        })
                        break;
                    }
                }
            })
        })
    })


    it('登录并检查自己的权限', function(done){
        var data = {
            account: DATA.account,
            password: PASSWORD
        }

        //登录
        doAction('mine', 'PUT', data, function(status, content, xhr){
            DATA.member_id = content.member_id
            expect(content.member_id).to.be.a('number')

            doAction('mine', 'GET', null, function(status, content, xhr){
                expect(content.role).to.be.eql('u')
                done()
            })
        })
    })

    it('查看在项目中的权限 -> d', function(done){
        var url = 'project/' + DATA.project_id
        doAction(url, 'GET', null, function(status, content, xhr){
            expect(content.role).to.be.eql('d')
            done()
        })
    })

    it('未经授权创建项目', function(done){
        var data = {
            status: "new",
            "title": "测试项目",
            "description": "项目的介绍",
            "start_date": NOW,
            "end_date": NOW
        }

        doAction('project', 'POST', data, function(status, content){
            expect(status).to.be(403)
            done()
        })
    })


//    it('未经授权创建用户', function(){
//        doAction(module, 'POST', {
//            username: DATA.account,
//            password: PASSWORD,
//            email: EMAIL,
//            gits: GITS
//        }, function (status, content, xhr) {
//            expect(status).to.be.a(403)
//        })
//    })
});