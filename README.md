### BHF

  BHF（Black Heart Factory）是芒果TV前端团队开发的用于团队协作与沟通的工具．

  该项目基于以下技术或软件： coffee-script, mysql, nodejs, gitlab， expressjs, redis
  
  用户涉及到Leader, 设计，产品，开发，测试人员.
  
  它解决了以下问题：
  
    1. 确定产品需求，留下产品对每一处需求改动的"足迹"，以免在开发过程中程序猿背锅而＂死无对证＂．
    2. 绑定开发者的 git commit到需求和bug上，每一处功能和bug有"码"可查．
    3. 解决周报问题，自动统计绑定了需求和bug的commit信息，可以分团队，成员进行每周工作内容概览．
    4. 开发文档． 把接口需求，接口，接口使用说明统一到此平台，避免前后端沟通成本
    5. 还有很多功能，如bug,需求等新问题的通知等，涉及到了微信企业号，chrome插件，邮件通知等．
    6. 支持ios客户端．（源代码待公布）
    
#### 安装说明


  bhf-api 为 后端API, 提供基于RESTful的API接口

  bhf-spark 为前端代码，采用silky (https://github.com/wvv8oo/silky) 构建
  
  message-center 为通知服务，独立于bhf可以提供公开接口给其他人使用，目前仅服务于 bhf
  
  notification-center-sdk ［在bhf-api的package.json中可以看到］为bhf通知中心的API，用来直接调取已部署的通知服务 [ message-center ]．
  
  bhf-middle-server 用于对外网提供访问内网API的方式，打破内网访问限制
```
  主要为ios客户端提供服务．因为bhf部署在内网，而且手机端不通过vpn无法访问内网，通过该服务，不需要拨vpn ios可以访问内网的接口
  当然性能一般，只能维持20-40个并发
```

#### 贡献
 
 由于信息敏感已删除git history. 主要贡献者如下(括号内为github账户)：
 
    xuedudu@gmail.com (xydudu)
  
    wvv8oo@gmail.com  (wvv8oo)
    
    wangbin@mgtv.com
    
    501246946@qq.com (zixuan86)
    
    kevinsu1989@gmail.com  (kevinsu1989)
    
    ec.huyinghuan@gmail.com (huyinghuan)
    
#### LICENSE

  MIT