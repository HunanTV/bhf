exports.schema =
  name: "webhook"
  fields:
  	# 钩子对应的项目id
    project_id: "integer"
    # 触发事件，现有：issue,comment,mention
    trigger: "text"
    # 钩子url
    url: "text"