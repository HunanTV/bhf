define [
  'ng'
], (_ng)->
  return {
    directiveModule: _ng.module("mic.directives", ["mic.services", "mic.filters"])
    controllerModule: _ng.module("mic.controllers", ["mic.services"])
    serviceModule: _ng.module("mic.services", [])
    filterModule: _ng.module("mic.filters", [])
  }