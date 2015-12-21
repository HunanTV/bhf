#issue的分类
exports.schema =
  name: "issue_category"
  fields:
    project_id: "integer"
    #分类名称
    title: ""
    #短名称，用于message指令
    short_title: ""