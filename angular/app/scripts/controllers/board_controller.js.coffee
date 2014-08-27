angular.module("agilytics").controller "BoardController", ($scope, $http, $location,
                                                           $stateParams, $timeout, $rootScope,
                                                           boardDataService)->
  $scope.board = {id: $stateParams.boardId}
  $scope.releaseManager = {} # for release manager
  $scope.categoryManager = {} # for release manager
  $scope.canSaveBoard = =>
    $scope.board.name && $scope.board.run_rate_cost

  $scope.cancelEdit = =>
    $scope.edit = false

  $scope.editBoard = =>
    $scope.edit = true
    $scope.categories = null

  $scope.saveBoard = ->
    data = { board: $scope.board }
    boardDataService.save scope.board.id, $rootScope.siteId, data, (data)->
      $scope.edit = false
      $scope.board = data
      window.location.reload()

  showGraph = (id, title, categories, series, xAxis, enableLegend, isPercent)->
    #http://jsfiddle.net/gh/get/jquery/1.9.1/highslide-software/highcharts.com/tree/master/samples/highcharts/demo/area-stacked/
    options =
      chart:
        type: "column"

      title:
        text: title

      xAxis:
        categories: categories
        labels:
          rotation: 45
          step: 2

        tickmarkPlacement: "on"

      yAxis:
        title:
          text: xAxis

      legend:
        enabled: enableLegend
        align: 'center',
        verticalAlign: 'top',
        floating: true,
        x: 0,
        y: 30

      tooltip:
        shared: true

      plotOptions:
        column:
          stacking: "normal"
          lineColor: "#666666"
          lineWidth: 1
          marker:
            enabled: false
            lineWidth: 1
            radius: 2
            lineColor: "#666666"

      series: series

    if isPercent
      options.yAxis.min = 0
      options.yAxis.max = 100

    $("\##{id}").highcharts options

  boardDataService.metricsForBoard($stateParams.boardId, $rootScope.siteId, (stats, board, data)->
    $scope.stats = stats
    $scope.board = board
    $scope.tags = []

    sg = ->
      sprints = data.sprints

      showGraph("velocity", "By Velocity", sprints, data.velocities.series, "Story Points", true)
      showGraph("velocityPercent", "By % Velocity", sprints, data.velocities.seriesPercent, "Percent Story Points",
        false, true)
      showGraph("counts", "By Count", sprints, data.counts.series, "Number")
      showGraph("countsPercent", "By % Count", sprints, data.counts.seriesPercent, "Percent of Count", false, true)

    $scope.editBoard()
    $timeout(sg, 0)
  )

  this