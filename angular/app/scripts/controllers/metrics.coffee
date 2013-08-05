class @MetricsController

  constructor: ($scope, agileCubeService)->

    agileCubeService.getCube( (cube)->
      #todo temporary
      window.cube = cube
      $scope.cube = cube
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
