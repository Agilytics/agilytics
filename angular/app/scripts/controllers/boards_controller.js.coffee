angular.module("agilytics").controller "BoardsController", ($scope, $http, $location, $stateParams)->

  $scope.href = (board)-> window.location.hash = "sites/#{$stateParams.siteId}/boards/#{board.id}"

  $http.get("/api/boards.json?site_id=#{$stateParams.siteId}").success((data)->
    $scope.boards = data
  )

  this

