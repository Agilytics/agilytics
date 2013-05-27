class @MetricsController

  constructor: ($scope, agileCubeService)->
    $scope.model = {}
    gridService.getBoards( (boards, assignees)->
        $scope.model.boards = boards
        $scope.model.assignees = assignees
    )

    this
@MetricsController.$inject = ['$scope', 'agileCubeService']