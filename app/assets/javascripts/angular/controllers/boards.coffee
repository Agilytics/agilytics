class @BoardsController
  constructor: ($scope, $http)->
    @scope = $scope
    @scope.boardsModel = {
      selectedBoards: []
    }
    @http = $http

#BoardsController.$inject = ['$scope', '$http'];