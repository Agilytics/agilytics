class @SprintController

  constructor: ($scope, agileCubeService, $stateParams)->
    agileCubeService.getCube( (cube)->
      $scope.sprint = cube.origCube.sprints[$stateParams.sprintId]
      window.sprint = $scope.sprint
    )
    this

@SprintController.$inject = ['$scope', 'agileCubeService', '$stateParams']
