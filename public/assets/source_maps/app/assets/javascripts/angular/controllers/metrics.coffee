class @MetricsController

  constructor: ($scope, agileCubeService)->

    agileCubeService.getCube( (cube)->
      #todo temporary
      window.cube = cube
      $scope.cube = cube
    )
    this

@MetricsController.$inject = ['$scope', 'agileCubeService']
