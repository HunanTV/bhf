###
  issue
###
_BaseEntity = require('bijou').BaseEntity
_AssetIssueRelation = require './asset_issue_relation'
_async = require 'async'
_common = require '../common'
_memberEntity = require './member'
_projectMemberEntity = require './project_member'
_teamMemberEntity = require './team_member'

#定义一个Project类
class Issue extends _BaseEntity
  constructor: ()->
    super require('../schema/issue').schema

  getIssueAndCreator: (issue_id, cb)->
    sql = "SELECT A.*, realname, email FROM issue A
        LEFT JOIN member B ON A.creator = B.id
        WHERE A.id = #{issue_id}"

    @execute sql, (err, result)-> cb err, result[0]

  #完成某个issue，将会触发一系列操作，比如说发邮件等
  finishedIssue: (id, member_id, cb)->
    data =
      id: id
      status: 'done'
      finish_time: Number(new Date())

    #找到并检查是否有owner，如果没有owner，则将owner设置为member_id
    self = @
    @findById id, (err, result)->
      return err if err
      #没有找到id
      return cb null, result if not result
      data.owner = member_id if not result.owner
      #保存数据
      self.save data, cb

  #改变issue的状态
  changeStatus: (issue_id, status, cb)->
    data = status: status
    data.finish_time = null if status is 'new'

    #修改状态
    @entity().where('id', '=', issue_id).update(data).exec cb

  fetch: (cond, pagination, cb)->
    #选项
    options =
      pagination: pagination
      fields: (query)->
        fields = "A.*, (SELECT realname FROM member WHERE member.id = A.owner) AS owner_name,
                				          (SELECT realname FROM member WHERE member.id = A.creator) AS creator_name,
                				          (SELECT title FROM project WHERE project.id = A.project_id) AS project_name"
        query.select query.knex.raw(fields)

      #在查询之前，对query再处理
      beforeQuery: (query, isCount)->
        #指定项目的id
        if(cond.project_id)
          query.where 'A.project_id', cond.project_id
        else
          #未指定项目的id，则查用户所有的项目
          query.join 'project_member AS B', (-> this.on 'A.project_id', '=', 'B.project_id'), 'left'
          query.where 'B.member_id', '=', cond.member_id

        #查用户关注的
        if cond.follow
          query.join 'issue_follow AS C', (-> this.on 'A.id', '=', 'C.issue_id'), 'left'
        #只取未完成的
        if(cond.status is 'undone')
          query.whereIn 'status', ['doing', 'pause', 'new']
#          query.where 'status', '<>', 'trash'
        else if cond.status instanceof Array
          query.whereIn 'status', cond.status
        else if typeof cond.status is 'string'
          query.where 'status', cond.status
        else
          #默认是不获取trash的数据
          query.where 'status', '<>', 'trash'

        #指定标签git
        if cond.tag
          query.where 'tag', cond.tag
        else
          #如果没有指定tag，其实应该查issue
          query.whereIn 'tag', ['issue', 'form']

        #指定责任人
        query.where 'owner', cond.owner if cond.owner isnt undefined
        #指定版本
        query.where 'version_id', cond.version_id if cond.version_id
        #指定分类
        query.where 'category_id', cond.category_id if cond.category_id

        #查用户自己的
        if cond.myself
          query.where(->
            this.where 'owner', cond.member_id
            this.orWhere 'creator', cond.member_id
            this.whereIn 'A.id', query.knex.raw("SELECT issue_id FROM issue_split WHERE owner = #{cond.member_id}")
          )
        if cond.follow
          query.where 'C.member_id', cond.member_id
#         query.where 'creator', cond.creator if cond.creator
        #指定hash
        query.where 'title', 'like', "%##{cond.hash}#%" if cond.hash
        #指定搜索关键字
        if cond.keyword
          query.where ()->
            this.where 'title', 'like', "%#{cond.keyword}%"
            #暂时不搜索内容
#            this.orWhere 'content', 'like', "%#{cond.keyword}%"

        #按状态排序
        orderBy = "case
                									when status = 'new' then 1
                									when status = 'doing' then 1
                									when status = 'pause' then 2
                									when status = 'done' then 3
                									else 4
                									end"

        query.orderBy query.knex.raw(orderBy), 'asc'
        query.orderBy 'timestamp', 'DESC'

#        console.log query.toString()
    @find null, options, cb

  #build时间范围查询条件
  ###
  queryTimeRange: (query, field, param)->
    return if not param
    list = param.split('|')
    #包括开始时间
    if list[0]
      start = new Date list[0]
      query.where field, '>=', start

    if list[1]
      end = new Date list[0]
      query.where field, '<=', end
  ###

  ###
    获取项目的讨论
    1. tag为project
    2. 有comment的issue
  ###
  #这部分代码有代重构
  getDiscussion: (cond, pagination, cb)->
    keyword = "%#{cond.keyword}%" if cond.keyword
    self = @
    sql = "SELECT :fields FROM issue WHERE project_id = #{cond.project_id} AND status <> 'trash'
        		      AND (tag = 'project' OR tag = 'discussion')"
    sql += " AND (title LIKE ? OR content LIKE ?)" if cond.keyword

    #不再取有评论的issue，仅取discussion, tag=project是为了兼容
    #OR id in (SELECT issue_id FROM comment WHERE project_id = #{project_id})
    queue = []
    #统计
    queue.push(
      (done)->
        countSql = sql.replace ':fields', 'count(id)'
        entity = self.entity().knex.raw(countSql, [keyword, keyword])
        entity.exec (err, result)->
          return done err if err

          #取第一行第一列
          for key, value of result[0][0]
            done err, value
            break
    )

    #搜索
    queue.push(
      (count, done)->
        fields = "*, (SELECT realname FROM member WHERE member.id = issue.creator) AS realname,
                				          (SELECT COUNT(*) FROM comment WHERE issue_id = issue.id) comment_count"
        sql += "ORDER BY always_top DESC, timestamp DESC limit #{pagination.limit} offset #{pagination.offset}"
        sql = sql.replace ':fields', fields
        entity = self.entity().knex.raw(sql, [keyword, keyword])
        entity.exec (err, result)->
          done err, count, result && result[0]
    )

    _async.waterfall queue, (err, count, result)->
      return cb err if err

      pagination.recordCount = count
      pagination.pageCount = self.pageCount(pagination)

      data =
        items: result
        pagination: pagination
      cb err, data

  #http://127.0.0.1:14318/api/project/1/discussion

  #查询指定时间内的issue
  findIssueInRange: (start_time, end_time, condition, assigned, cb)->
    sql = "SELECT A.*, B.title AS project_name FROM issue A LEFT JOIN project B ON A.project_id = B.id
        		              WHERE 1 = 1 #{condition} AND "
    sql +=                   " A.finish_time BETWEEN #{start_time} AND #{end_time}"  if  assigned
    sql += 		               " A.timestamp BETWEEN #{start_time} AND #{end_time}"    if !assigned
    sql +=                " AND A.status <> 'trash' AND A.tag IN ('issue', 'form')"

    @entity().knex.raw(sql).exec (err, result)->
      return cb err if err
      cb err, result[0]


  findSplitIssueInRange: (start_time, end_time, condition, assigned, cb)->
    sql = "SELECT A.content, A.id as split_id, A.issue_id as id, A.project_id, A.owner, A.creator, A.plan_finish_time, A.finish_time, A.timestamp, A.status, A.title, B.title AS issue_title, C.title AS project_name FROM issue_split A LEFT JOIN issue B ON A.issue_id = B.id "
    sql += " LEFT JOIN project C ON B.project_id = C.id "
    sql += "              WHERE 1 = 1 #{condition} AND "
    sql +=                   " A.finish_time BETWEEN #{start_time} AND #{end_time}"  if  assigned
    sql +=                   " A.timestamp BETWEEN #{start_time} AND #{end_time}"    if !assigned
    sql +=                " AND A.status <> 'trash' "
    console.log sql
    @entity().knex.raw(sql).exec (err, result)->
      return cb err if err
      cb err, result[0]

  #获取已关联的issue
  findAssignedIssue: (cond, cb)->
    subsql = "AND A.owner = #{cond.member_id} AND A.splited <> 1"
    subsql += " AND A.project_id = #{cond.project_id}" if cond.project_id
    #subsql = "AND A.owner = #{cond.member_id}"
    #兼容旧数据，等客户端准备好后，必需要指定project_id
    #subsql += " AND A.project_id = #{cond.project_id}" if cond.project_id
    @findIssueInRange cond.start_time, cond.end_time, subsql, true, cb

  #获取已关联的拆分issue
  findAssignedSplitIssue: (cond, cb)->
    subsql = "AND A.owner = #{cond.member_id} "
    subsql += " AND A.project_id = #{cond.project_id}" if cond.project_id

    @findSplitIssueInRange cond.start_time, cond.end_time, subsql, true, cb

  #查找所有的未关联任务
  findUnassignedIssue: (cond, cb)->
    subsql = " AND A.owner IS null "
    subsql += " AND A.project_id = #{cond.project_id}" if cond.project_id
    #subsql = " AND A.owner IS null"
    #兼容旧数据，等客户端准备好后，必需要指定project_id
    #subsql += " AND A.project_id = #{project_id}" if project_id
    @findIssueInRange cond.start_time, cond.end_time, subsql, false, cb

  #查找所有的未关联的拆分任务
  findUnassignedSplitIssue: (cond, cb)->
    subsql = " AND A.owner IS null "
    subsql += " AND A.project_id = #{cond.project_id}" if cond.project_id
    @findSplitIssueInRange cond.start_time, cond.end_time, subsql, false, cb

  #获取报表，可以指定用户，也可以是自己
  report: (cond, cb)->
    result = assigned: [], unassigned: []
    self = @
    queue = []

    #获取所有用户，或者当前项目的用户
    queue.push (
      (done)->
        if cond.project_id
          #查找一个项目的所有用户
          _projectMemberEntity.projectMembers cond.project_id, done
        else if cond.team_id and parseInt(cond.team_id) isnt 0
          #查找一个团队的所有用户
          con = 
            "team_id": cond.team_id
            "status": 1
          _teamMemberEntity.teamMembers con, done
        else
          #查找当前用户
          _memberEntity.findById cond.member_id, ['id AS member_id', 'username', 'realname'], (err, member)->
            done err, [member]
    )

    queue.push(
      (members, done)->
        index = 0
        _async.whilst(
          -> index < members.length
          (done)->
            member = members[index++]
            cond.member_id = member.member_id
            self.findAssignedIssue cond, (err, result)->
              return done err if err
              member.issue = result
              done err
          (err)-> done err, members
        )
    )

    # 查询关联到人的拆分任务
    queue.push(
      (members, done)->
        index = 0
        _async.whilst(
          -> index < members.length
          (done)->
            member = members[index++]
            cond.member_id = member.member_id

            self.findAssignedSplitIssue cond, (err, result)->
              return done err if err
              member.issue = member.issue.concat result
              done err
          (err)-> done err, members
        )
    )

    #查询未关联到人的，即没有owner的任务
    queue.push(
      (members, done)->
#        console.log "拆分任务："
#        console.log members
        #如果是取团队和个人的任务，则不用取没关联的任务
        if cond.team_id 
          result.assigned = members
          result.unassigned = []
          return done null, members
        else if not cond.all
          result = members[0].issue
          return done null, members
        result.assigned = members
        #如果是项目的任务，继续获取未关联的issue
        self.findUnassignedIssue cond, (err, data)->
          result.unassigned = data
          done null, members
    )

    #查询未关联到人的，即没有owner的拆分任务
    queue.push(
      (members, done)->
        #如果是取团队和个人的任务，则不用取没关联的任务
        if cond.team_id 
          result.assigned = members
          result.unassigned = []
          return done null
        else if not cond.all
          result = members[0].issue
          return done null
        result.assigned = members
        #如果是项目的任务，继续获取未关联的issue
        self.findUnassignedSplitIssue cond, (err, data)->
          result.unassigned = result.unassigned.concat data
          done null
    )

    _async.waterfall queue, (err)-> cb err, result

  myreport: (start_time, end_time, member_id, cb)->
    cond = " AND A.owner = #{member_id}"
    @findIssueInRange start_time, end_time, cond, true, cb


  #统计分析单个用户的数据
  statisticOfMember: (project_id, member_id, cb)->
    result = {}
    self = @
    queue = []

    queue.push(
      (done)-> self.countIssueOfProject project_id, member_id, (err, count)->
        result.total = count
        done err
    )

    queue.push(
      (done)-> self.countDelayIssueOfProject project_id, member_id, (err, count)->
        result.delay = count
        done err
    )

    queue.push(
      (done)-> self.countIssueByStatusOfProject project_id, member_id, 'done', (err, count)->
        result.done = count
        done err
    )

    queue.push(
      (done)-> self.countCommitOfProject project_id, member_id, (err, count)->
        result.commit = count
        done err
    )
    _async.series queue, (err)-> cb err, result

  #获取用户的统计数据
  statisticOfMembers: (project_id, data, cb)->
    self = @
    index = 0
    _async.whilst(
      (-> return index < data.members.length)
      ((done)->
        member = data.members[index++]
        self.statisticOfMember project_id, member.profile.id, (err, stat)->
          member.stat = stat
          done err
      )
      cb
    )

  #汇总统计指定project下的issue总数量，不包括status=trash和tag=project的，member可以不指定
  countIssueByStatusOfProject: (project_id, member_id, status, cb)->
    sql = "SELECT COUNT(id) FROM issue WHERE tag IN ('issue', 'form') AND project_id = #{project_id}"
    status = [status] if typeof status is 'string'
    sql += " AND status in ('#{status.join('\',\'')}')"
    sql += " AND owner = #{member_id}" if member_id

    @scalar sql, cb

  #汇总统计指定project下的issue总数量，不包括status=trash和tag=project的，member可以不指定
  countIssueOfProject: (project_id, member_id, cb)->
    sql = "SELECT COUNT(id) FROM issue WHERE tag IN ('issue', 'form') AND status <> 'trash' AND project_id = #{project_id}"
    sql += " AND owner = #{member_id}" if member_id

    @scalar sql, cb

  #汇总延误数
  countDelayIssueOfProject: (project_id, member_id, cb)->
    #plan_finish_time < #{Number(new Date())}AND
    sql = "SELECT COUNT(*) FROM issue WHERE tag IN ('issue', 'form') AND status IN ('new', 'doing', 'pause')
        		      AND project_id = #{project_id}"
    sql += " AND owner = #{member_id}" if member_id

    @scalar sql, cb

  #汇总commit数
  countCommitOfProject: (project_id, member_id, cb)->
    sql = "SELECT COUNT(*) FROM commit WHERE project_id = #{project_id}"
    sql += " AND creator = #{member_id}" if member_id
    @scalar sql, cb

  ###
    统计分析，截至当前时间，指定项目
  ###
  statistic: (project_id, cb)->
    self = @
    queue = []
    result =
      overview: total: 0, delay: 0
      members: []

    #查出总任务数
    queue.push(
      (done)->
        self.countIssueOfProject project_id, null, (err, count)->
          result.overview.total = count
          done err
    )


    #查出总Commit数量
    queue.push(
      (done)->
        self.countCommitOfProject project_id, null, (err, count)->
          result.overview.commit = count
          done err
    )

    #延误数，即plan_finish_time<now的，状态为doing/new/pause的
    queue.push(
      (done)->
        self.countDelayIssueOfProject project_id, null, (err, count)->
          result.overview.delay = count
          done err
    )

    #每个用户的任务数量
    queue.push(
      (done)->
        #查出所有的用户
        options = fields: ['id', 'username', 'email', 'realname', 'git', 'role']
        _memberEntity.find {}, options, (err, data)->
          result.members.push profile: member for member in data
          self.statisticOfMembers project_id, result, done
    )

    _async.series queue, (err)-> cb err, result

  #获取最新的评论及issue的信息
  lastCommentAndIssue: (issue_id, cb)->
    sql = "SELECT A.*, B.content AS reply_content, B.creator AS replier
      FROM issue A LEFT JOIN
      (SELECT * FROM comment WHERE issue_id = #{issue_id} ORDER BY id LIMIT 1) AS B
      ON B.issue_id = A.id where A.id = #{issue_id}"

    @execute sql, (err, result)-> cb err, result && result[0]

  #获取一个issue的所有讨论者
  findDiscussMember: (issue_id, cb)->
    sql =  "SELECT id, email, realname FROM
      	(SELECT creator FROM issue WHERE id = #{issue_id}
      	UNION
      	SELECT creator FROM comment WHERE issue_id = #{issue_id})
      AS A LEFT JOIN member B ON A.creator = B.id"
    @execute sql, cb

  getSingleIssue: (id, member_id, cb)->
    sql = "SELECT
          B.realname AS creator_name, C.realname AS owner_name, A . *,
          (SELECT COUNT(*) FROM issue_follow WHERE issue_id=#{id} AND member_id = #{member_id}) AS follow
      FROM
          issue A
              LEFT JOIN
          member B ON A.creator = B.id
              LEFT JOIN
          member C ON A.owner = C.id
      WHERE
          A.id = #{id}"
    @execute sql, (err, data)-> cb err, data && data[0]

  #统计测试任务（未完成和已完成的数量）
  statTestIssue: (project_id, cb)->
    self = @
    data = {}
    queue = []
    sql = "SELECT COUNT(*) FROM issue WHERE tag = 'test' AND project_id = #{project_id}"

    queue.push(
      (done)->
        self.scalar "#{sql} AND status <> 'trash'", (err, total)->
          data.all = total
          done err
    )

    queue.push(
      (done)->
        completeSql = "#{sql} AND status <> 'trash' AND status <> 'done'"
        self.scalar completeSql, (err, total)->
          data.undone = total
          done err
    )

    _async.waterfall queue, (err)-> cb err, data


  #批量添加任务
  addIssues: (issue_list, cb)->
    @entity().insert(issue_list).exec (err, data)->
      cb err, data
      


module.exports = new Issue()
