angular.module("agilytics").controller "BoardController", ($scope, $http, $location, $stateParams)->

  alert "sites/#{$stateParams.siteId}/boards/#{$stateParams.boardId}"
  $scope.href = (board)-> window.location.hash = "sites/#{$stateParams.siteId}/boards/#{board.id}"

this

