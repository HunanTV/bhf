"use strict"
define [
  'ng'
  '../ng-module'
], (_ng, _module) ->
  _module.serviceModule
  .factory('LOADING', [->
      loading = -> $("#loading").fadeIn()
      loaded = -> $("#loading").fadeOut()
      {
        loading: loading
        loaded: loaded
      }
])