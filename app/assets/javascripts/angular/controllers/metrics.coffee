class @MetricsController

  constructor: ($scope, agileCubeService)->

    agileCubeService.getCube( (cube)->
        $scope.cube = cube
    )
    this

@MetricsController.$inject = ['$scope', 'agileCubeService']