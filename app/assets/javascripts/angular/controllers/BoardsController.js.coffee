class @BoardsController

  constructor: ($scope, gridService)->

    $scope.model = {}
    gridService.getCube( (boards, assignees)->
#        $scope.model.boards = boards
#        $scope.model.assignees = assignees
    )

    this

@BoardsController.$inject = ['$scope', 'agileCubeService']