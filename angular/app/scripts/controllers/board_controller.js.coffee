angular.module("agilytics").controller "BoardController", ($scope, $http, $location,
                                                           $stateParams, $timeout, $rootScope,
                                                           boardStatsService)->

  boardStatsService.state.board.id = $stateParams.boardId

  $scope.state = boardStatsService.state
  $scope.board = $scope.state.board

  $scope.from = $stateParams["from"]
  $scope.to = $stateParams["to"]

  $scope.canFilter = -> $scope.state.eventRange.from && $scope.state.eventRange.to
  $scope.filter = =>
    window.location.hash= "/boards/#{$stateParams.boardId}/#{$rootScope.agilyticsContext}?from=#{$scope.state.eventRange.from.event.pid}&to=#{$scope.state.eventRange.to.event.pid}"

  $scope.releaseManager = {} # for release manager
  $scope.categoryManager = {} # for release manager

  $scope.canSaveBoard = =>
    $scope.state.board.name && $scope.state.board.run_rate_cost

  $scope.cancelEdit = =>
    $scope.edit = false

  $scope.editBoard = =>
    $scope.edit = true
    $scope.categories = null

  $scope.saveBoard = ->
    data = { board: $scope.state.board }
    boardStatsService.save $scope.state.board.id, $rootScope.siteId, data, (data)->
      $scope.edit = false
      boardStatsService.state.board = data
      window.location.reload()

  this