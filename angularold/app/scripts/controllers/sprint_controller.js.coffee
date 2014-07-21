class @SprintController

  constructor: ($scope, agileCubeService, $stateParams)->
    agileCubeService.getCube( (cube)->
      $scope.sprint = cube.origCube.sprints[$stateParams.sprintId]
      $scope.colors =
        removedAdded: "#FDE0B5"
        missedAdded: "#fad2d2"
        removedCommitted: "#f90"
        missedCommitted: "#fa3939"
        addedVelocity: "#5CFA5C"
        changedVelocity: "#A9DFAB"
        committedVelocity: "green"
        totalVelocity: "black"
    )
    this

@SprintController.$inject = ['$scope', 'agileCubeService', '$stateParams']