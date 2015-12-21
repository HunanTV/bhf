exports.schema =
  name: "comment"
  fields:
    project_id: "integer"
    issue_id: "integer"
    creator: "integer"
    content: "text"
    timestamp: "bigInteger"
    status: "integer"