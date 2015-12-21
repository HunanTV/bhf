#_Commit = require '../biz/commit'
_path = require 'path'

testCommit = ()->
  commit = new _Commit(
    member_id: -1
  )

  commit.postCommits(null, ()->console.log(arguments))

testParse = ()->
  commit = new _Commit(
    member_id: -1
  )

  data =
    project_id: 10
    issue_id: 10
    creator: undefined
    sha: "text"
    other: 192

  console.log commit.parse(data)

#testParse()
#test
