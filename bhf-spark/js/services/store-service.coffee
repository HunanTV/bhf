"use strict"
define [
  'ng'
  '../ng-module'
], (_ng, _module) ->
  _module.serviceModule
  .service('STORE', ['$q', 'API', ($q, API)->

    service = {}

    class CacheData
      constructor: ()->
        @data
      update: (entity, params)->
        self = @

        if source instanceof SegmentEntity
          return source.retrieve(params)

#        defer = $q.defer()
#        API.get(url).then((result)->
#          self.data = result
#          defer.resolve result
#        )
#        defer.promise
      get: ()-> @data
      set:(data)-> @data = data

    service.user = new CacheData()
    service.session = new CacheData()
    service.projectMemberList = new CacheData()
    service.projectCategory = new CacheData()
    service.projectVersion = new CacheData()
    service.teamMemberList = new CacheData()
    service.teamCategory = new CacheData()
    return service
  ])