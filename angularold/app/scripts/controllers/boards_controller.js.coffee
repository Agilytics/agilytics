class BoardsController

  constructor: ($scope, $http)->
    alert 'hello'

angular.module('agilytics').controller('BoardsController',
  [
      "$scope",
      "$http",
      ($scope, $http)->
        alert '111'
        new BoardsController($http, agiliticsUtils)
  ]
)
