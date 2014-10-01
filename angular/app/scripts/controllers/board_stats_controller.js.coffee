angular.module("agilytics").controller "BoardStatsController", ($scope, $http, $location,
                                                           $stateParams, $timeout, $rootScope,
                                                           boardStatsService)->

  $rootScope.agilyticsContext = "stats"
  fromEventPid = $stateParams["from"]
  toEventPid = $stateParams["to"]


  $scope.board = {id: $stateParams.boardId}

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

  showControlChart = (id, title, categories, yAxisTitle, sprintsEvents, series, value_id)->
    sum = 0
    for s in sprintsEvents
      sum += s.event[value_id] * 1

    mean = Math.round( sum / sprintsEvents.length )

    squared_variation = 0
    values = []
    for s in sprintsEvents
      value = s.event[value_id] * 1
      values.push value
      variation = value - mean
      squared_variation += Math.pow(variation, 2 )

    standardDeviation = Math.round Math.sqrt( squared_variation / sprintsEvents.length )

    ticks = [
        mean + standardDeviation * 3
        mean + standardDeviation * 2
        mean + standardDeviation * 1
        mean
    ]

    ticks.push if (mean + standardDeviation * -1) > 0 then mean + standardDeviation * -1 else 0
    ticks.push if (mean + standardDeviation * -2) > 0 then mean + standardDeviation * -2 else 0
    ticks.push if (mean + standardDeviation * -3) > 0 then mean + standardDeviation * -3 else 0

    # Don't want to affect other lines
    series = _.clone(series)
    series.marker = _.clone(series.marker)

    series.color = "black"
    series.lineWidth = 3

    series.marker.radius = 5

    options =
      chart:
        type: "line"

      title:
        text: title

      subtitle:
        text: "Standard Deviation(#{standardDeviation}) Mean(#{mean})"

      xAxis:
        categories: categories
        labels:
          rotation: 45
          step: 2

        tickmarkPlacement: "on"

      legend:
        enabled: false
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
            lineColor: "black"

      series: [ series ]

    sigmaColor = "#999"
    yAxis = {
      title:
        text: yAxisTitle

      max: ticks[0]

      plotLines: [
        value: ticks[0]
        color: "rgba(162,29,33,.75)"
        width: 2
        zIndex: 3
      ,
        value: ticks[1]
        color: sigmaColor
        width: 2
        zIndex: 3
      ,
        value: ticks[2]
        color: sigmaColor
        width: 2
        zIndex: 3
      ,
        value: ticks[3]
        color: "rgba(24,90,169,.75)"
        width: 2
        zIndex: 3
      ,
        value: ticks[4]
        color: sigmaColor
        width: 2
        zIndex: 3
      ,
        value: ticks[5]
        color: sigmaColor
        width: 2
        zIndex: 3
      ,
        value: ticks[6]
        color: "rgba(162,29,33,.75)"
        width: 2
        zIndex: 3
      ]
    }

    options.yAxis = yAxis

    $("\##{id}").highcharts options


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

  $scope.sprintRange = { from: $stateParams["from"], to: $stateParams["to"] }
  $scope.board = boardStatsService.state.board
  $scope.events = boardStatsService.state.sprintEvents

  boardStatsService.getEvents($stateParams.boardId, $rootScope.siteId, $scope.sprintRange, (res)->
    $scope.stats = res.filteredStats

    $scope.tags = []

    sg = ->
      sprints = res.filteredSeriesData.sprints

      showControlChart("velocity-control-chart", "Velocity Control Chart", sprints, "Velocity", res.filteredEvents, res.filteredSeriesData.velocities.series[0], "total_velocity")

      showGraph("velocity", "By Velocity", sprints, res.filteredSeriesData.velocities.series, "Story Points", true)
      showGraph("velocityPercent", "By % Velocity", sprints, res.filteredSeriesData.velocities.seriesPercent, "Percent Story Points",
        false, true)
      showGraph("counts", "By Count", sprints, res.filteredSeriesData.counts.series, "Number")
      showGraph("countsPercent", "By % Count", sprints, res.filteredSeriesData.counts.seriesPercent, "Percent of Count", false, true)

    $timeout(sg, 0)

  )

  this