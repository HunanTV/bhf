###
  webhook
###
_entity = require '../entity'
_ = require 'lodash'
_async = require 'async'
_http = require('bijou').http
_guard = require './guard'
_uuid = require 'node-uuid'


exports.get = (client, cb)->
  data =
    project_id: client.params.project_id

  _entity.webhook.find data, cb


exports.save = (client, cb)->
  data = client.body
  data.project_id = client.params.project_id

  queue = []

  #必需要是项目的leader，才能操作
  queue.push(
    (done)->
      _guard.projectPermission data.project_id, client.member, (err)-> done err
  )

  queue.push(
    (done)->
      _entity.webhook.save data, (err, result)->
        done err, result
  )

  _async.waterfall queue, cb

exports.delete = (client, cb)->
  data = id: client.params.id

  queue = []

  #必需要是项目中的成员，才能操作
  queue.push(
    (done)->
      _guard.projectPermission client.params.project_id, client.member, '*-g', (err)-> done err
  )

  queue.push(
    (done)->
      _entity.webhook.remove data, (err, result)->
        done err, result
  )

  _async.waterfall queue, cb









exports.hook = (url, data)->
  request.post(url, {form: data, json: true},(err, res, body)->
    
  )





