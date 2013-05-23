class @BoardsController

  constructor: ($scope, gridService)->

    gridService.getBoards( (boards, assignees)->

      $scope.model = {}
      $scope.model.boards = boards
      $scope.model.assignees = assignees

    )
    this

#MetricsController.$inject = ['$scope', 'gridService']