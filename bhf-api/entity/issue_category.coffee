###
  issue的分类
###
_BaseEntity = require('bijou').BaseEntity
_async = require 'async'
_common = require '../common'
_ = require 'lodash'

class IssueCategory extends _BaseEntity
  constructor: ()->
    super require('../schema/issue_category').schema

  #获取分类，并统计分类
  fetchWithCount: (product_id, cb)->
    sql = "SELECT
        *,
        (SELECT
                COUNT(*)
            FROM
                issue
            WHERE
                issue.category_id = issue_category.id) AS issue_total,
        (SELECT
                COUNT(*)
            FROM
                issue
            WHERE
                issue.category_id = issue_category.id
                    AND (issue.status = 'doing'
                    OR issue.status = 'new'
                    OR issue.status = 'pause')) AS issue_undone_total
    FROM
        issue_category
    WHERE
        project_id = #{product_id}"

    @execute sql, cb

module.exports = new IssueCategory