_assert = require 'assert'

_gitlab = require '../biz/gitlab'
_cache = require '../cache'
_gitMap = require '../biz/git_map'

initDB = require('bijou').initDB
_cache.init()

_database =
  client: 'mysql',
  connection:
    host     : '127.0.0.1',
    user     : 'root',
    password : '123456',
    database : 'bhf'

initDB _database


describe("Git Fork", ->

    it("获取git project id", (done)->
      client =
        params:
          project_id: 28
        body:
          git_id: 966
        member:
          member_id: 8

      _gitlab.fork(client, (err, result)->
        done()
      )
    )

    it("关联git到project", (done)->
      client =
        params:
          project_id: 11
        body:
          gitlab_url: "git@git.hunantv.com:huyinhuan/script-for-bhf-update-gitmap-table.git"
        member:
          member_id: 8

      _gitlab.addGitToProject(client, (err, result)->
        done()
        console.log err
      )
    )

    it("根据token和项目名称查询项目是否存在", (done)->
      token = "AsXdp8cq5MSn8p9U53iZ"
      name = "BHF-API"
      _gitlab.isExistsProjectInMyAccountByName(token, name, (err, result)->
        console.log err, result
        done()
      )
    )

    it("创建新项目, 项目名已存在", (done)->
      client =
        params:
          project_id: 11
        body:
          gitlab_name: "BHF-test-create"
        member:
          member_id: 8

      _gitMap.createGitForProject(client, (err, result)->
        done()
      )

    )

    it.only("在git集合中获取属于自己的git", (done)->
      _gitlab.getMyGitListInGiven('AsXdp8cq5MSn8p9U53iZ', [178, 222, 332],
        (err, result)->
          console.log err if err
          console.log result
          done()
      )
    )
)