'use strict'
  
define [
  'ng'
  './services/index'
  'filters'
  './project/index'
  './issue/index'
  './comment/index'
  './member/index'
  './commit/index'
  './assets/index'
  './report/index'
  './team/index'
  './stream/index'
  './gitlab/index'
  'angularRoute'
  'v/ui-router'
  './global-directives/index'
  './controllers'
], (_ng) ->
  _ng.module 'mic', [
    'ngRoute'
    'mic.services'
    'mic.directives'
    'mic.controllers'
    'mic.filters'
    'ui.router'
  ]