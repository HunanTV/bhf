module.exports =
  remote: "http://localhost:3000"
  token: "hyh.bhf.hunantv.com"
 # target_server: "http://bhf.hunantv.com"
 # target_server_host: "bhf.hunantv.com"
  target_server: "http://localhost:3002"
  target_server_host: "localhost:3002"
  ###
    api等待目标服务器响应时间，超过这个响应就结束这个响应
    可以设置为false
    为false时则根据目标服务器实际响应情况进行处理
  ###
  timeout: false
  isDev: false