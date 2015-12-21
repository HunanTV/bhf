## apache bench 测试脚本

post.txt 内容如下

```
your_name=fredrik&fruit=ApricotFromAB
```

命令如下
```
ab -n 1 -c 1 -p post.txt -T "application/x-www-form-urlencoded" http://localhost:3000/api/account/token
```