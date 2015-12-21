#针对issue的操作日志
exports.schema =
  name: "log"
  fields:
    #触发这个日志的用户
    member_id: "integer"
    #版本名称
    target_id: "integer"
    #日志类型，issue/asset
    type: ""
    #日志内容
    content: 'text'
    #日志发生的日期
    timestamp: 'bigInteger'
