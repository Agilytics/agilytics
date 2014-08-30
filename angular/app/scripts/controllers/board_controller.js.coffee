angular.module("agilytics").controller "BoardController", ($scope, $http, $location,
                                                           $stateParams, $timeout, $rootScope,
                                                           boardDataService)->



  $scope.dateRange = {
    from: ""
    to: ""
  }


  $scope.canFilter = -> $scope.dateRange.from && $scope.dateRange.to
  $scope.filter = =>
    window.location.hash= "/boards/#{$stateParams.boardId}/#{$scope.dateRange.from.event.pid}/#{$scope.dateRange.to.event.pid}"

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

  fromEventPid = $stateParams["from"]
  toEventPid = $stateParams["to"]

  $scope.sprintRange = { to: toEventPid, from: fromEventPid }

  console.log "BoardController - #{$scope.sprintRange.from} - #{$scope.sprintRange.to}"

  boardDataService.getEvents($stateParams.boardId, $rootScope.siteId, { from: fromEventPid, to: toEventPid }, (res)->
    #$scope.stats = res.stats
    $scope.board = res.board
    $scope.tags = []
    $scope.events = res.sprintEvents

    $scope.dateRange.from = res.eventRange.from
    $scope.dateRange.to = res.eventRange.to

    sg = ->
      sprints = res.filteredSeriesData.sprints

      showGraph("velocity", "By Velocity", sprints, res.filteredSeriesData.velocities.series, "Story Points", true)
      showGraph("velocityPercent", "By % Velocity", sprints, res.filteredSeriesData.velocities.seriesPercent, "Percent Story Points",
        false, true)
      showGraph("counts", "By Count", sprints, res.filteredSeriesData.counts.series, "Number")
      showGraph("countsPercent", "By % Count", sprints, res.filteredSeriesData.counts.seriesPercent, "Percent of Count", false, true)

    $timeout(sg, 0)

  )

  this