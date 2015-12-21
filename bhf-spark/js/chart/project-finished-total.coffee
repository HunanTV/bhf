define [
  'v/echarts'
  'utils'
  '_'
], (_echarts, _utils, _)->

  class FinishedTotalRate
    constructor: (@container)->
      @option =
        legend: x: 'right', padding: [8, 20, 5, 5]
        grid: x: 40, y: 60, x2: 20, y2: 20, borderWidth: 0, borderColor: 'transparent'
        tooltip:
          trigger: "axis"

        toolbox: show: false
        calculable: true
        xAxis: [
          type: "category"
          boundaryGap: false
        ]

      @chart = echarts.init @container
      @chart.setOption @option


    #获取所有的天
    getAllDays: (startTime, endTime)->
      days = {}
      total = endTime.diff startTime, 'days'
      for index in [0..total]
        days[startTime.add(1, 'days').format('YYYY-ww')] = 0
      days

    #剪切Top5
    cutTopN: (data)->
      list = (value for key, value of data)
      list.sort (left, right)-> if left.total > right.total then -1 else 1
      list.splice 0, 5

    #准备数据
    prepareSeries: (originDays, data)->
      result = {}
      _.map data, (item)->
        if not (line = result[item.id])
          line = result[item.id] =
            total: 0
            id: item.id
            days: _.clone originDays
            name: item.name

        line.total += item.total
        line.days[item.timestamp] = item.total
      @cutTopN result

    getSeries: (data, color)->
      rgba = _utils.hex2rgba color
      color = _utils.formatString 'rgba({0}, {1}, {2}, {3})', rgba.r, rgba.g, rgba.b, 0.6

      name: data.name
      type: 'line'
      smooth: true
      symbol: 'none'
      itemStyle:
        normal:
          color: color
          lineStyle: color
          areaStyle:
            color: color
            type: "default"
      data: (value for key, value of data.days)

    reload: (startTime, endTime, origin)->
      originDays = @getAllDays startTime, endTime
      data = @prepareSeries originDays, origin
      colors = ['#2f91da', '#f5ae46', '#6cbf3d', '#eeeb2c', '#a14ad9', '#f6bd0e']

      series = (@getSeries(item, colors[index]) for item, index in data)

      xAxis = [
        type: 'category'
        data: _.keys originDays
        splitLine: show: false
        axisLabel:
          formatter: (text)->
            text.replace(/\D/, '年第') + '周'
      ]

      yAxis = [
        type: 'value'
        splitLine: show: false
      ]
      option =
        xAxis: xAxis
        yAxis: yAxis
        legend: data: _.pluck(data, 'name'), x: 'right', padding: [8, 20, 5, 5]
        series: series

      @chart.setOption _.extend(@option, option), true
        
