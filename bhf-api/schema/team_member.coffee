#组目与成员之间的关系
exports.schema =
  name: "team_member"
  fields:
    team_id: "integer"
    member_id: "integer"
    inviter: "integer"
    status: "integer"
    #该成员在组中的角色
    role: ''