_path = require 'path'
_conn = require('../db-connect').conn()
isDev = require("../config").develop

class BaseBean
  constructor: (tableName)->
    @tableName = tableName
    @conn = _conn
    @init()

  init: ->
    throw new Error('cannot find table') if @tableName is null
    @model = @conn.Model(@tableName, isDev)


  save: (data)->
    data.status = 1
    @model.save(data)

  table: ()-> @model.table()

  delOne: (key, value)->
    @update({status: 0}, [key, "=", value])

  delMul: (key, arr)-> @model.delMul(key, arr)

  sql: (sqlStr)-> @model.sql(sqlStr)

  update: (data, where)-> @model.update(data, where)



module.exports  = BaseBean