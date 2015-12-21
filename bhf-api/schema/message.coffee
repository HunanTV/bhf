#离线消息
exports.schema =
  name: "message"
  fields:
    #消息发送者id
    sender_id: 'integer'
    #收信人
    receiver_id: "integer"
    #消息内容
    content: "text"
    #相关链接
    link: "text"
    #发生的日期
    timestamp: 'bigInteger'
    #状态
    status: ''