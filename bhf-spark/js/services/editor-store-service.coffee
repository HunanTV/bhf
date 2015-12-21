"use strict"
define [
  'ng'
  '../ng-module'
], (_ng, _module) ->
  _module.serviceModule
  .service('EDITORSTORE', ['$q', 'API', ($q, API)->

    service = {}

    class _myStorage
      constructor: ()->
        @storage = (JSON.parse localStorage.getItem("EDITORSTORE")) || []

      getItem: (key)->
        @storage = JSON.parse localStorage.getItem("EDITORSTORE") || []
        return item.value for item in @storage when item.key is key if @storage

      setItem: (key, string, auto)->
        time = new Date() * 1
        # 每5秒钟自动保存一次
        return if time - @time < 5000 && auto
        @time = time
        if @storage
          for item in @storage when item.key is key
            item.value = string 
            item.time = time
            localStorage.setItem "EDITORSTORE", JSON.stringify(@storage) 
            return
        @storage.push {key: key, value: string, time: time}
        localStorage.setItem "EDITORSTORE", JSON.stringify(@storage)
      getList: ()->
        JSON.parse localStorage.getItem("EDITORSTORE")

    myStorage = new _myStorage()
    service =
      get: (key)->
        myStorage.getItem key
      set: (key, string, auto)->
        myStorage.setItem key, string, auto
      list: ()->
        myStorage.getList()
    return service
  ])


