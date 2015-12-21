exports.schema =
  name: "member"
  fields:
    username: ""
    email: ""
    password: ""
    realname: ""
    weixin: ""
    role: ""
    status: ""
    options: "text"
    open_id: {type: 'integer', index: true}
    gitlab_username: ""
    gitlab_token: ""
    notification: ""