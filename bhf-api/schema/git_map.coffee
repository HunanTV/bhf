#用户与git帐号地址的对应
exports.schema =
  name: "git_map"
  fields:
    #类型，project/member
    type: ""
    #对应项目的id或者用户的id
    target_id: "integer"
    #git地址，或者用户的git邮箱
    git: ""
    #git地址对应的gitlab的id
    git_id: "integer"