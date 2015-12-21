BaseBean = require './base'
_ = require 'lodash'
class User extends BaseBean
  constructor: (tablename)->
    super

  ###
    Desc: 根据条件获取符合条件的记录
    1. 假如第一个参数为String 那么：
      @params {String} 查询的字段
      @params {String} or {Number} or 其他基本数据类型

    2. 否则按第二种方式处理
      @params {JSON Object} 查询的条件的集合

    @return promiss
  ###
  getByField: (field, value)->
    if _.isString(field)
      where = {}
      where[field] = value
    else
    where = field
    @table().select("*").where(where)

  ###
    根据用户名和密码 获取 用户信息
    @params {string}  用户名
  ###
  getByUsernameAndPassword: (username, password)->
    user =
      username: username
      password: password

    @getByField(user).then((rows)-> rows[0])

  ###
    Desc: 根据单个条件获取符合条件的记录数目
    1. 假如第一个参数为String 那么：
      @params {String} 查询的字段
      @params {String} or {Number} or 其他基本数据类型

    2. 否则按第二种方式处理
      @params {JSON Object} 查询的条件的集合

    @return promiss
  ###
  getRecordCount: (field, value)->
    if _.isString(field)
      where = {}
      where[field] = value
    else
      where = field

    @table().count("*").where(where).then((result)->
      result[0]["count(*)"]
    )

  isExistUser: (username)->
    @getRecordCount({username: username})

module.exports = new User('user')