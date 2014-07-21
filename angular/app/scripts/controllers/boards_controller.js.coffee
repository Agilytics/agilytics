angular.module("agilytics").controller "BoardsController", ($scope, $http) ->

  $http.get("/api/boards.json").success((data)->
    $scope.boards = data
  )

  this

