angular.module("agilytics").controller "BoardsController", ($rootScope, $scope, $http, $location, $stateParams, $timeout)->
  $scope.boards = []
  $scope.notBoards = []

  updateBoards = ->
    getVelocitiesAndDoSparkLines()
    $scope.boards.length = 0
    $scope.notBoards.length = 0
    for board in $scope.allBoards
      if board.to_analyze
        $scope.boards.push board
      else
        $scope.notBoards.push board

  $scope.goToBoard = (board)->
    window.location.hash= "/boards/#{board.id}/stats"

  $scope.saveBoards = ->

    todo = ->
      data = { boards: $scope.allBoards }
      $http(
        url: "/api/boards/updateBoards.json?siteId=#{$rootScope.siteId}"
        method: "POST"
        data: JSON.stringify(data)
        headers: {'Content-Type': 'application/json'}
      ).success((data, status, headers, config) ->
        updateBoards()
      ).error((data, status, headers, config) ->
        alert 'error'
      )
    $timeout(todo,0)

  $http.get("/api/boards.json?site_id=#{$rootScope.siteId}").success((data)->
    $scope.allBoards = data
    updateBoards()
  )

  getVelocitiesAndDoSparkLines = -> $http.get("/api/boards/velocities.json?site_id=#{$rootScope.siteId}").success (data) -> doSparkLines(data)

  doSparkLines = (data)->

    for id, board of data.boards
      chart = {}
      $td = $("\##{id}")
      if $td.length
        $td.highcharts "SparkLine",
          series: [
            data: board.sprintVelocities
            pointStart: 1
          ]
          tooltip:
            headerFormat: "<span style=\"font-size: 10px\">" + $td.parent().find("th").html() + ", Q{point.x}:</span><br/>"
            pointFormat: "<b>{point.y}.000</b> USD"

          chart: chart


  Highcharts.SparkLine = (options, callback) ->
    defaultOptions =
      chart:
        renderTo: (options.chart and options.chart.renderTo) or this
        backgroundColor: null
        borderWidth: 0
        type: "area"
        margin: [
          2
          0
          2
          0
        ]
        width: 120
        height: 20
        style:
          overflow: "visible"

        skipClone: true

      title:
        text: ""

      credits:
        enabled: false

      xAxis:
        labels:
          enabled: false

        title:
          text: null

        startOnTick: false
        endOnTick: false
        tickPositions: []

      yAxis:
        endOnTick: false
        startOnTick: false
        labels:
          enabled: false

        title:
          text: null

        tickPositions: [0]

      legend:
        enabled: false

      tooltip:
        backgroundColor: null
        borderWidth: 0
        shadow: false
        useHTML: true
        hideDelay: 0
        shared: true
        padding: 0
        positioner: (w, h, point) ->
          x: point.plotX - w / 2
          y: point.plotY - h

      plotOptions:
        series:
          animation: false
          lineWidth: 1
          shadow: false
          states:
            hover:
              lineWidth: 1

          marker:
            radius: 1
            states:
              hover:
                radius: 2

          fillOpacity: 0.25

        column:
          negativeColor: "#910000"
          borderColor: "silver"

    options = Highcharts.merge(defaultOptions, options)
    new Highcharts.Chart(options, callback)

  this

