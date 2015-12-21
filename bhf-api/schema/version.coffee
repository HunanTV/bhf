#项目的版本，一个项目可以有多个版本
exports.schema =
  name: "version"
  fields:
    project_id: "integer"
    #版本名称
    title: ""
    #版本短名称，用于git commit的message，^v1.0
    short_title: ""
    #版本状态，（doing, normal, done），doing只能有一个，done表示此版本已经完成，不显示在版本切换列表
    status: {type: '', default: 'normal'}