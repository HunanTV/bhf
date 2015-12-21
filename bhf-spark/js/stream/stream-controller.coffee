"use strict"
define [
  '../ng-module'
  '../utils'
], (_module, _utils, _template) ->

	_module.controllerModule.
    controller('streamListController', ['$scope', '$timeout', 'API', ($scope, $timeout, API)->
		partByDay = (items)->
		    days = []
		    day = {
		    	timestamp: 0,
		    	items: []
		    }
		    for item, index in items
		    	if (index > 0 and new Date(item.timestamp).toDateString() is new Date(items[index - 1].timestamp).toDateString()) or index is 0
			    	day.items.push item
			    else
			    	days.push {
				    	timestamp: day.timestamp,
				    	items: day.items
			    	}
			    	day.items = [item]
		    	day.timestamp = item.timestamp
		    	days.push day if index + 1 is items.length
		    days
		API.stream().retrieve().then (result)->
			$scope.days = partByDay result
			$timeout(hljs.initHighlighting, 500)
		API.session().retrieve().then (result)->
			$scope.member = result
	])