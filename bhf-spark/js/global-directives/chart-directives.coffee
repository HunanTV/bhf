define [
  '../ng-module'
  'utils'
  'moment'
], (_module, _utils, _moment)->

  _module.directiveModule
  #项目中，issue完成数量的TOP5
  .directive('issueFinishedTotalChart', ['API', (API)->
    restrict: 'A'
    replace: true
    link: (scope, element, attrs)->
      #延时加载
      require ['chart/project-finished-total'], (_ProjectFinishedTotal)->
        chart = new _ProjectFinishedTotal(element[0])
        beginTime = _moment('2014-05-01')
        startTime = _moment().subtract(1, 'years').startOf('day')
        #不能在最初的时间前
        startTime = beginTime if startTime.isBefore(beginTime)
        endTime = _moment().endOf('day')
        params =
          startTime: startTime.valueOf()
          endTime: endTime.valueOf()

        attr_id = if attrs.id then attrs.id else null

        API.report()[attrs.name](attr_id).issueFinish().retrieve(params).then (result)->
            chart.reload startTime, endTime, result

        scope.$on 'team:chart:change',(event, id, flag)->
          return if flag isnt attrs.flag

          start = _moment().subtract(1, 'years').startOf('day')
          #不能在最初的时间前
          start = beginTime if startTime.isBefore(beginTime)
          
          API.report()[attrs.name](id).issueFinish().retrieve(params).then (result)->
            chart.reload start, endTime, result
  ])

  #成员issue完成数据的TOP5
  .directive('memberFinishedTotalChart', ()->
    restrict: 'E'
    replace: true
    link: (scope, element, attrs)->
  )