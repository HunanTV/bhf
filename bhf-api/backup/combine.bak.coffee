_entity = require '../entity/project'
_async = require 'async'
fs = require 'fs-extra'
_path = require('path')
_ = require "lodash"

asset = (fromProject, toProject, cb) ->
  sql = "update asset set project_id = #{toProject} where project_id = #{fromProject}"
  _entity.entity().knex.raw(sql).exec (err, result)->
    cb and cb(err,result)

comment = (fromProject, toProject, cb) ->
  sql = "update comment set project_id = #{toProject} where project_id = #{fromProject}"
  _entity.entity().knex.raw(sql).exec (err, result)->
    cb and cb(err,result)

commit = (fromProject, toProject, cb) ->
  sql = "update commit set project_id = #{toProject} where project_id = #{fromProject}"
  _entity.entity().knex.raw(sql).exec (err, result)->
    cb and cb(err,result)


git_map = (fromProject, toProject, cb) ->
  sql = "update git_map set target_id = #{toProject} where type='project' and target_id = #{fromProject}"
  _entity.entity().knex.raw(sql).exec (err, result)->
    cb and cb(err,result)

issue = (fromProject, toProject, cb)->
  sql = "update issue set project_id = #{toProject}  where project_id = #{fromProject}"
  _entity.entity().knex.raw(sql).exec (err, result)->
    cb and cb(err,result)

project_member = (fromProject, toProject, cb)->
  repeatSql = "select a.id from project_member as a, project_member as b " +
                "where a.project_id = #{fromProject} and b.project_id = #{toProject} and a.member_id = b.member_id"
  deleteSql = "delete from project_member where id in "
  replaceSql = "update project_member set project_id = #{toProject}  where project_id = #{fromProject}"
  sqls = [repeatSql, deleteSql, replaceSql]
  _results = []
  _async.whilst(
    () ->
        sqls.length
    , (done) ->
        sql = sqls.shift()
        if sqls.length isnt 1
          return _entity.entity().knex.raw(sql).exec (err, result)->
            _results.push result
            done()

        condition = _results[0][0]
        return done() if not condition.length
        _condition = ""
        _.map( condition, (item) ->
          _condition = "#{_condition}\'#{item.id}\',"
        )
        _condition = _condition.substr(0, _condition.length - 1)
        sql = "#{sql} (#{_condition}) and project_id = #{fromProject}"
        _entity.entity().knex.raw(sql).exec (err, result)->
          _results.push result
          done()

    , (err, r) ->
  )

project = (fromProject, toProject, cb)->
  sql = "update project set status = 'trash'  where id = #{fromProject}"
  _entity.entity().knex.raw(sql).exec (err, result)->
    cb and cb(err,result)

directory = (fromProject, toProject, cb)->
  cwd = process.cwd()
  source = path.join(cwd, "assets", fromProject)
  destination =  path.join(cwd,'assets', toProject)
  fs.copy(source, destination, (err) ->
    result = if err then  "project assets maybe not exists" else "copy success"
    cb and cb(err,result)
  )


combine = (fromProject, toProject, cb) ->
  dolist = [asset, comment, commit, git_map, issue, project_member, project, directory]
  result = []
  error = []
  _async.whilst(
    () ->
      dolist.length
    ,(done)->
      _do = dolist.shift()
      _do fromProject, toProject, (err, _result)->
        result.push _result
        error.push err
        done()
    ,() ->
      cb and cb(error,result)
  )

module.exports = combine