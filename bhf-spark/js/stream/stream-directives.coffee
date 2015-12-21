define [
  '../ng-module'
  '../utils'
  't!../../views/stream/stream-all.html'
], (_module,_utils, _tmplAll) ->

    _module.directiveModule
    .directive('streamList',['$timeout', 'API', ($timeout, API)->
        restrict: 'E'
        replace: true
        template: _utils.extractTemplate '#tmpl-stream-list', _tmplAll
        link: (scope, element, attrs)->

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
                scope.days = partByDay(result)



    ])
    .directive('streamIssueDay',['API',()->
        restrict: 'E'
        replace: true
        template: _utils.extractTemplate '#tmpl-stream-issue-day', _tmplAll
        link: (scope, element, attrs)->
            scope.day = JSON.parse attrs.day

            scope.today = "today" if new Date(scope.day.timestamp).toDateString() is new Date().toDateString()

    ])
    .directive('streamListCell',['API',()->
        restrict: 'E'
        replace: true
        template: _utils.extractTemplate '#tmpl-stream-list-cell', _tmplAll
        link: (scope, element, attrs)->
            scope.item = JSON.parse attrs.item

    ])

    .directive('streamIssueAssigned',['API',()->
        restrict: 'E'
        replace: true
        template: _utils.extractTemplate '#tmpl-stream-issue-assigned', _tmplAll
        link: (scope, element, attrs)->
            scope.item = JSON.parse attrs.item

    ])

    .directive('streamIssueStatusChange',['API',()->
        restrict: 'E'
        replace: true
        template: _utils.extractTemplate '#tmpl-stream-issue-status-change', _tmplAll
        link: (scope, element, attrs)->
            scope.item = JSON.parse attrs.item

    ])

    .directive('streamIssueCommentPost',['API',()->
        restrict: 'E'
        replace: true
        template: _utils.extractTemplate '#tmpl-stream-issue-comment-post', _tmplAll
        link: (scope, element, attrs)->
            scope.item = JSON.parse attrs.item

    ])

    .directive('streamIssueAssetPost',['API',()->
        restrict: 'E'
        replace: true
        template: _utils.extractTemplate '#tmpl-stream-issue-asset-post', _tmplAll
        link: (scope, element, attrs)->
            scope.item = JSON.parse attrs.item

    ])

    .directive('streamIssueMention',['API',()->
        restrict: 'E'
        replace: true
        template: _utils.extractTemplate '#tmpl-stream-issue-mention', _tmplAll
        link: (scope, element, attrs)->
            scope.item = JSON.parse attrs.item

    ])

    .directive('streamTeamInvitation',['API',()->
        restrict: 'E'
        replace: true
        template: _utils.extractTemplate '#tmpl-stream-team-invitation', _tmplAll
        link: (scope, element, attrs)->
            scope.item = JSON.parse attrs.item

    ])


