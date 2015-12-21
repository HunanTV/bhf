#    Author: 易晓峰
#    E-mail: wvv8oo@gmail.com
#    Date: 6/24/15 4:48 PM
#    Description:
_async = require 'async'

_member = require './member'
_projectMember = require './project_member'
_gitMap = require './git_map'
_project = require './project'

module.exports =
  member: _member
  gitMap: _gitMap
  projectMember: _projectMember
  project: _project
  init: (cb)->
    queue = []
    queue.push (done)-> _member.init (err)-> done err
    queue.push (done)-> _projectMember.init (err)-> done err
    queue.push (done)-> _gitMap.init (err)-> done err
    queue.push (done)-> _project.init (err)-> done err

#    queue.push(
#      (done)->
#        console.log _gitMap.get '17229398@qq.com'
#        done null
#    )

    _async.waterfall queue, cb