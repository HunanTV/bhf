#    Author: 易晓峰
#    E-mail: wvv8oo@gmail.com
#    Date: 6/1/15 9:27 AM
#    Description:  成员与硬件设备之间的关系，一般用于绑定设备号进行推送

exports.schema =
  name: "member_device"
  fields:
    #关联的用户id
    member_id: {type: 'integer', index: true}
    #设备号
    device_id: ""
    #设备类型
    device_type: ""
    #发生的日期
    timestamp: 'bigInteger'