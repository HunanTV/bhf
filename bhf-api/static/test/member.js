describe('测试用户模块', function(){
    var GITS = [USERNAME + '@test.com', USERNAME + '@test1.com']
    var module = 'mine'
    it('退出当前帐号，防止上一个session还在', function(done){
        doAction(module, 'DELETE', null, function(status){
            //第一次退出，如果从未登录，则会是401，否则是200
            expect([200, 401]).to.contain(status)
            done()
        })
    })

    it('测试未登录状态', function(done){
        doAction(module, 'GET', null, function(status, content, xhr){
            expect(status).to.be(401)
            done()
        })
    })

    it('使用管理员帐号登录', function(done){
        var data = {
            account: 'admin',
            password: '888888'
        }

        doAction(module, 'PUT', data, function(status){
            expect(status).to.be(200)
            done()
        })
    })


    //依赖前前的管理员登录
    it('用管理员的帐号添加一个用户' + USERNAME, function(done){
        doAction(module, 'POST', {
            username: USERNAME,
            password: PASSWORD,
            email: EMAIL,
            role: 'a',
            gits: GITS
        },function(status, content, xhr){
            expect(status).to.be(200)
            MEMBERID = content.id
            //检查返回id是否正确
            expect(content.id).to.be.a('number')
            done()
        })
    })

    it('用错误的密码登录', function(done){
        doAction(module, 'PUT', {
            account: USERNAME,
            password: PASSWORD + 'a'
        }, function(status, content, xhr){
            expect(status).to.be(406)
            done()
        })
    })

    it('用错误的帐号登录', function(done){
        doAction(module, 'PUT', {
            account: USERNAME + 'a',
            password: PASSWORD
        }, function(status, content, xhr){
            expect(status).to.be(406)
            done()
        })
    })

    it('用刚刚的帐号登录', function(done){
        doAction(module, 'PUT', {
            account: USERNAME,
            password: PASSWORD
        }, function(status){
            expect(status).to.be(200)

            doAction(module, 'GET', null, function(status1, content, xhr){
                expect(status1).to.be(200)
                expect(content.username).to.eql(USERNAME)
                done()
            })

        })
    })


    it('测试获取用户的资料', function(done){
        var url = 'account/profile'
        doAction(url, 'GET', null, function(status, content, xhr){
            expect(content.username).to.eql(USERNAME)
            expect(content.gits.length).to.be(GITS.length)
            done()
        });
    })

    it('测试修改用户资料', function(done){
        var url = 'account/profile'
        var data = {
            realname: '张三',
            email: 'zs@hunantv.com',
            gits: ['test1@git.com', 'test2@git.com', 'test3@git.com']
        }

        doAction(url, 'PUT', data, function(){
            doAction(url, 'GET', null, function(status, content, xhr){
                expect(content.realname).to.eql(data.realname)
                expect(content.gits.length).to.be(data.gits.length)
                done()
            })
        });
    })

    it('测试退出', function(done){
        doAction(module, 'DELETE', null, function(status, content, xhr){
            expect(status).to.be(200)
            done()
        })
    })

    it('测试退出是否成功', function(done){
        doAction(module, 'GET', null, function(status, content, xhr){
            expect(status).to.be(401)
            done()
        })
    })

    it('用管理员的帐号登录，以接下来的测试做准备', function(done){
        doAction(module, 'PUT', {
            account: 'admin',
            password: '888888'
        }, function(status, content, xhr){
            ROOTMEMBERID = content.member_id
            expect(content.member_id).to.be.a('number')
            done()
        })
    })
})