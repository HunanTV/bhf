"use strict"

define(['v/socket.io'], function(){
    var Notify = function(){}
    //======================== web notify start
    var extend = function(source, destination){
        destination = destination || {}
        for(var property in destination){
            source[property] = destination[property]
        }
        return source
    }

    var special_setting = {
        "success":{
            type: "success",
            force: true
        },
        "error":{
            type: 'error'
        },
        "warn":{
            type: 'warning'
        },
        'info':{
            type: 'information',
            layout: 'topRight',
            force: true,
            timeout: false
        }
    }

    var getSetting = function(type){
        var base_setting =  {
            layout: 'top',
            theme: 'defaultTheme',
            type: 'alert',
            dismissQueue: true, // If you want to use queue feature set this true
            timeout: 4 * 1000, // delay for closing event. Set false for sticky notifications
            force: false, // adds notification to the beginning of queue when set to true
            modal: false,
            maxVisible: 3, // you can set max visible notification for dismissQueue true option,
            killer: false, // for close all notifications before show
            closeWith: ['click'], // ['click', 'button', 'hover']
            buttons: false // an array of buttons
        }
        return extend(base_setting, special_setting[type])
    }

    var base = function(content, setting){
        var body = extend(setting, { text: content})
        noty(body)
    }

    var notifyFactory = function(type){
        return function(content, config){
            var setting = getSetting(type)
            var settting = extend(setting, config)
            base(content, setting)
        }
    }


    Notify.success = notifyFactory('success')
    Notify.error = notifyFactory('error')
    Notify.warn = notifyFactory('warn')
    Notify.info = notifyFactory('info')
    //======================== web notify end


    //======================== Desktop notify start

    Notify.desktop = {}

    var so = io.connect("ws://"+window.location.hostname+":8001")

    //消息签名
    var getSignature = function(response){
        var senderName = response.sender.realname
        return  "\n\n             send by " + senderName
    }

    var jumpLink =  function(response){
        if(response.data.link){
            window.location.href = response.data.link
        }
    }

    //给项目成员或者所有人发送消息
    var doTalk = function(response){
        var title = response.data.title || ''
        var content = response.data.content || ''
        deskShow(title, content, response)
    }

    //任务发起人的任务被完成通知
    var doIssueChange = function(response){
        var title
        if(response.data.issue.status !== 'done'){
            title = '将状态改为->' + response.data.issue.status
        }else{
            title = '完成了任务'
        }

        title = response.sender.realname + title
        var content = response.data.issue.title
        deskShow(title, content, response)
    }

    //任务被指定通知
    var doIssueAssigned = function(response){
        var plan_finish_time, title = "您有新任务"

        if(plan_finish_time = response.data.issue.plan_finish_time){

            title +=  "，于" + moment(plan_finish_time).format("MM月DD日") + "到期"
        }

        var content = response.data.issue.title
        deskShow(title, content, response)
    }
    //某人被@通知
    var doMemtion = function(response){
        var title = response.data.issue.title
//        var content = "";
//        if(response.data.comment){
//            content = $(response.data.comment.content).text()
//        }
//        if(content.length > 20){
//            content = content.substr(0, 20) + "..."
//        }
        deskShow('有人在提到你了', title, response)
    }

    //被团队邀请
    var doTeamInvitation = function(response){

        var content = response.sender.realname + "邀请你加入团队【" + response.data.teamName + "】";

        deskShow(response.sender.realname + '邀请你加入团队', content, response)
    }

    var doEvent = {
        'talk:project': doTalk,
        'talk:all': doTalk,
        "issue:status:change": doIssueChange,
        'issue:assigned' : doIssueAssigned,
        'mention': doMemtion,
        'team:invitation': doTeamInvitation
    }

    so.on('message', function(response){
        var _doShow = doEvent[response.event] || function(){ console.log('unknown event', response) }
        _doShow(response)
    })

    so.on('connect', function(){
        so.emit('ready')
    })


    var isSupport = (function(){
        if(!("Notification" in window)){
            Notify.warn('您的浏览器不支持桌面通知，建议使用Chrome,Firefox 或者 Safari',{timeout: 5 * 1000})
            return false
        }
        if (Notification.permission === 'default') {
            Notification.requestPermission(function (permission) {
                if(!('permission' in Notification)) {
                    Notification.permission = permission;
                }
            })
        }
        if(Notification.permission === "denied"){
            var msg =  '该浏览器桌面通知已被禁用,推荐开启! 点击查看开启方式 '
            Notify.warn(msg,{
                timeout:false,
                callback: {
                    onClose: function(){
                        window.open("http://bhf.hunantv.com/project/17/issue/1506", "_blank" )
                    }
                }
            })
        }
        return true
    })()

    var deskShow = function(title, body, response){
        title = title ? title : 'BHF友好提醒: '
        body = body ? body : ''
        body = body + getSignature(response)
        if(!isSupport){
            Notify.info(title + body)
            return;
        }
        var options = {
            lang: "UTF-8",
            icon: '/images/desktop.png',
            body: body
        }
        var cb = function(){
            var notification = new Notification(title, options);
            notification.onclick = function(){
                jumpLink(response)
            }
        }
        if (Notification.permission === "granted") {
            cb()
            return;
        }
        if (Notification.permission === 'default') {
            Notification.requestPermission(function (permission) {
                if(!('permission' in Notification)) {
                    Notification.permission = permission;
                }
                if (permission === "granted") {
                    cb()
                }
            })
        }
        if(Notification.permission === 'denied'){
            Notify.info(title + body)
        }

    }

    var realMessage = function(event, data){
        var message = {
            event: event,
            data: data
        }
        so.emit('message', message)
    }

    Notify.desktop.online  = function(){
        so.emit('ready')
    }

    Notify.desktop.offline = function(){
        so.disconnect()
    }

    Notify.desktop.busy = function(){

    }

    Notify.desktop.toAll = function(broadcast){
        realMessage('talk:all', broadcast)
    }
    Notify.desktop.toProject = function(project_id, broadcast){
        broadcast.project_id = project_id
        realMessage('talk:project', broadcast)
    }
    Notify.desktop.toMember = function (member_id){
//        console.log('abc')
        broadcast.project_id = project_id
        realMessage('talk:member', broadcast)
    }
    //======================== Desktop notify end
    return Notify
})