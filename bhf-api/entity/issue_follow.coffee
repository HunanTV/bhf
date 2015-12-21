###
  用户关注issue
###
_BaseEntity = require('bijou').BaseEntity
_async = require 'async'
_common = require '../common'
_ = require 'lodash'

class IssueFollow extends _BaseEntity
	constructor: ()->
		super require('../schema/issue_follow').schema

	#获取分类，并统计分类
	getFollowList: (issue_id, cb)->

		sql = "SELECT
		    A.*, B.realname
		FROM
		    issue_follow A
		LEFT JOIN 
			member B
		ON
			A.member_id = B.id
		WHERE
		    A.issue_id = #{issue_id}"

		@execute sql, cb



module.exports = new IssueFollow