var root = '/api/'

function fetch(url, callback){
  $.ajax({
    url: url
  })
}

//关联某个素材到issue上
function linkAsset(issueId, assetId, callback){
  $.ajax({
    url: root + 'issue/' + issueId + '/asset',
    type: 'POST',
    data: {
      asset_id: assetId
    }
  });
}

function unlinkAsset(issueId, id, callback){
  $.ajax({
    url: root + 'issue/' + issueId + '/asset/' + id,
    type: 'DELETE'
  });
}

function changeStatus(issueId, status, callback){
  $.ajax({
    url: root + 'issue/status/' + issueId ,
    type: 'PUT',
    data: {
      status: status
    }
  });
}

function postIssue(projectId, callback){
  $.ajax({
    url: root + 'project/' + projectId + '/issue',
    type: 'POST',
    data: {
      "assets": [1, 2, 3, 4],
      //标题
      "title": "首页搜索栏要实时展示",
      //内容
      "content": "详细的描述",
      //标签，也就是分类
      "tag": "需求",
      //责任人
      "owner": "兰斌",
      //状态
      "status": "新建"
    }
  })
}

function postProject(callback){
  $.ajax({
    url: root + 'project',
    type: 'POST',
    data: {
      //项目标题
      "title": "芒果网首页'\"",
      //项目的详细描述
      "description": "芒果网的新版首页",
      //指定具体的联系人，这个联系人是需求方的项目负责人
      "contact": "张三",
      //预计开始日期，即需求方期待什么时间开始，日期格式为yyyy-MM-dd hh:mm:ss
      "start_date": "2014-03-20 10:10:10",
      //预计结束日期
      "end_date": "2014-03-20 10:10:10",
      //仓库地址，可不填
      "repos": "http://github.com/xxx/xxx"
    }
  })
}

function postComment(issue_id, callback){
  $.ajax({
    url: root + 'issue/' + issue_id + '/comment',
    type: 'POST',
    data: {
      "content": "请见#1 号issue"
    }
  })
}

function fetchProject(callback){
  $.ajax({
    url: root + 'project'
  })
}

function signUp(callback){
  $.ajax({
    url: root + 'mine',
    type: 'POST',
    data: {
      username: '兰斌',
      password: '123456'
    }
  })
}

function signIn(callback){
  $.ajax({
    url: root + 'mine',
    type: 'PUT',
    data: {
      username: '兰斌',
      password: '123456'
    },
    success: function(){
      if(callback) callback()
    }
  })
}

function signOut(callback){
  $.ajax({
    url: root + 'mine',
    type: 'DELETE'
  })
}

function getMember(callback){
  $.ajax({
    url: root + 'mine',
    type: 'get'
  })
}