exports.schema =
  name: "issue"
  fields:
    #标题
    title: ""
    #内容
    content: "text"
    #标签（废弃，用category_id代替）
    tag: ""
    #被分配任务的人
    owner: "integer"
    #创建者
    creator: "integer"
    #状态
    status: ""
    #创建时间
    timestamp: "bigInteger"
    #计划完成时间
    finish_time: "bigInteger"
    #对应project.id
    project_id: "integer"
    #优先级
    priority: "integer"
    #计划完成时间
    plan_finish_time: "bigInteger"
    #置顶
    always_top: 'boolean'
    #对应版本的id
    version_id: 'integer'
    #对应issue_category.id
    category_id: 'integer'
    #对应issue_category.id
    splited: 'boolean'