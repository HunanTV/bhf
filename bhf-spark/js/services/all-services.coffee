#通用的services
"use strict"
define [
  'ng'
  '../ng-module'
  'notify'
  'moment'
], (_ng, _module, _notify, _moment) ->
  _module.serviceModule
  .factory 'NOTIFY', ()-> _notify

  #获取周的列表
  .factory('WEEKLIST', ()->
    (total)->
      list = []
      now = _moment().startOf 'week'
      for index in [0..total]
        start = now.clone().subtract(index, 'weeks')
        end = start.clone().add(6, 'days')
        list.push
          text: start.clone().subtract(1, 'days').format('YYYY年第W周')
          start: start.startOf('days').valueOf()
          end: end.endOf('days').valueOf()
      list

  )

  #枚举
  .factory('ENUM', ->
    return {
      projectFlag:
        normal: 0
        wiki: 1
    }
  )

  .factory('HOST', ['$location', ($location)->
    parts = [$location.$$protocol, '://', $location.$$host]
    if $location.$$port isnt 80
      parts.push(':')
      parts.push($location.$$port)

    parts.join ''
  ])

