class @BoardsController

  constructor: ($scope, agileCubeService)->
    agileCubeService.getCube( (cube)->
      debugger
      $scope.cube = cube
    )
    this

@BoardsController.$inject = ['$scope', 'agileCubeService']