#!/bin/sh

echo "仅适用于服务器forever环境部署"

NODE_ENV=production PORT=8001 forever start --uid "bhf-api" -a -c coffee /home/dudu/www/bhf-api/app.coffee

#启动测试服务器
#NODE_ENV=production PORT=8002 forever start --uid "bhf-api-develop" -a -c coffee /var/www/bhf-api-develop/app.coffee