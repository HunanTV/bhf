#报表分析，与具体的entity无关

_util = require 'util'
_bijou = require('bijou')
_BaseEntity = _bijou.BaseEntity
_http = _bijou.http
_common = require '../common'

class Report extends _BaseEntity
  constructor: ()->
    super require('../schema/report').schema
  #针对项目的issue分析
  projectIssue: (startTime, endTime, cb)->
    sql = "SELECT
        COUNT(*) total, TMP.id, TMP.timestamp, A.title AS name
    FROM
        (SELECT
            project_id AS id,
                from_unixtime(finish_time / 1000, '%Y-%U') timestamp
        FROM
            issue
        WHERE
            finish_time between #{startTime} and #{endTime}
                AND status <> 'trash'
                AND tag <> 'project') AS TMP
            LEFT JOIN
        project AS A ON A.id = TMP.id
    GROUP BY TMP.id , TMP.timestamp
    ORDER BY TMP.id , TMP.timestamp ASC"

    @execute sql, cb

  memberIssue: (startTime, endTime, cb)->
    sql = "SELECT
        COUNT(*) total,
        TMP.owner AS id,
        TMP.timestamp,
        A.realname AS name
    FROM
        (SELECT
            owner,
                from_unixtime(finish_time / 1000, '%Y-%U') timestamp
        FROM
            issue
        WHERE
            finish_time between #{startTime} and #{endTime}
                AND status <> 'trash'
                AND tag <> 'project'
                AND owner > 0) AS TMP
            LEFT JOIN
        member AS A ON A.id = TMP.owner
    GROUP BY owner , timestamp
    ORDER BY owner , TMP.timestamp ASC"

    @execute sql, cb

  teamIssue: (team_id, startTime, endTime, cb)->
    sql = "SELECT
        COUNT(*) total,
        TMP.owner AS id,
        TMP.timestamp,
        A.realname AS name
    FROM
        (SELECT
            owner,
                from_unixtime(finish_time / 1000, '%Y-%U') timestamp
        FROM
            issue
        WHERE
            finish_time between #{startTime} and #{endTime}
                AND status <> 'trash'
                AND tag <> 'project'
                AND owner > 0) AS TMP
            LEFT JOIN
        member AS A ON A.id = TMP.owner
    WHERE A.id IN (SELECT member_id FROM team_member WHERE team_id=#{team_id} and status=1)
    GROUP BY owner , timestamp
    ORDER BY owner , TMP.timestamp ASC"
    @execute sql, cb


module.exports = new Report()