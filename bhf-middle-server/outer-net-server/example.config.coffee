module.exports =
  port: 3000
  token: "hyh.bhf.hunantv.com"
  ###
    外网等待 内网 响应处理的时间，
    如果超过这个时间， 那么则不等待客户端处理结果 直接返回 502
  ###
  timeout: 30000