class @BoardsController

  constructor: ($scope, agileCubeService)->
    agileCubeService.getCube( (cube)->
      $scope.cube = cube
    )
    this

@BoardsController.$inject = ['$scope', 'agileCubeService']