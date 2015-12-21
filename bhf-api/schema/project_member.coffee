#项目与成员之间的关系
exports.schema =
  name: "project_member"
  fields:
    project_id: "integer"
    member_id: "integer"
    #该成员在项目中的角色
    role: ''