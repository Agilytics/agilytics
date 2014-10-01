angular.module("agilytics").controller "TeamBoardController", ($scope, $http, $location,
                                                           $stateParams, $timeout, $rootScope,
                                                           boardTeamService, boardStatsService)->

  $rootScope.agilyticsContext = "team"

  calcStandardDeviation = (items)->
    sum = 0
    for item in items
      sum += item

    mean = Math.round( sum / items.length )

    squared_variation = 0
    values = []
    for value in items

      values.push value
      variation = value - mean
      squared_variation += Math.pow(variation, 2 )

    standardDeviation = Math.round Math.sqrt( squared_variation / items.length )

    mean: mean
    standardDeviation: standardDeviation

  showControlChart = (id, title, categories, yAxisTitle, mean, standardDeviation, averageSeries, otherSeries)->
    ticks = [
        mean + standardDeviation * 3
        mean + standardDeviation * 2
        mean + standardDeviation * 1
        mean
    ]
    ticks.push if (mean + standardDeviation * -1) > 0 then mean + standardDeviation * -1 else 0
    ticks.push if (mean + standardDeviation * -2) > 0 then mean + standardDeviation * -2 else 0
    ticks.push if (mean + standardDeviation * -3) > 0 then mean + standardDeviation * -3 else 0

    averageSeries.lineWidth = 3
    averageSeries.marker.radius = 5

    allSeries = [averageSeries].concat otherSeries

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
        enabled: true
        align: 'center'
        verticalAlign: 'bottom'

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

      series: allSeries

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

  boardStatsService.getEvents($stateParams.boardId, $rootScope.siteId, { from: $stateParams["from"], to: $stateParams["to"] }, (res)->
    includedSprints = {}
    for filteredSprint in res.filteredEvents
      includedSprints[filteredSprint.event.sprint_id] = true

    $scope.sprintRange = { from: $stateParams["from"], to: $stateParams["to"] }
    boardTeamService.getTeamStats($stateParams.boardId, $rootScope.siteId, (res)->

      sprints = {}
      assigneesSprints = {}
      assigneeSprints = {}
      for assignee in res.data
        if includedSprints[assignee.sprint_id] && assignee.sum && assignee.sum * 1

          unless sprints[assignee.sprint_id]
            sprints[assignee.sprint_id] =
              id: assignee.sprint_id
              name: assignee.sprint_name
              end_date: assignee.end_date

          unless assigneeSprints[assignee.assignee_id]
            assigneeSprints[assignee.assignee_id] =
              id:assignee.assignee_id
              name:assignee.assignee
              sprints: {}

          assigneeSprints[assignee.assignee_id].sprints[assignee.sprint_id] = assignee.sum * 1

          assigneesSprints[assignee.sprint_id] = { sum: 0, assignees: [] } unless assigneesSprints[assignee.sprint_id]
          assigneesSprints[assignee.sprint_id].assignees.push assignee
          assigneesSprints[assignee.sprint_id].sum += assignee.sum * 1

      averageAssignees = []

      assigneeSeries = {}
      for key, value of assigneesSprints
        value.averageAssigneeVelocity = value.sum / value.assignees.length
        averageAssignees.push value.averageAssigneeVelocity

      sprintCategories = []
      assigneeSeries = []
      assigneeSeriesObj = {}

      for key, sprint of sprints
        sprintCategories.push sprint.name
        for key, assignee of assigneeSprints
          unless assigneeSeriesObj[assignee.id]
            assigneeSeriesObj[assignee.id] = { name: assignee.name, data: [], lineWidth: 2, marker: { radius: 2, lineColor: "#DFDFDF" }, type: 'line'}
            assigneeSeries.push assigneeSeriesObj[assignee.id]

          assigneeSeriesObj[assignee.id].data.push if assignee.sprints[sprint.id] then assignee.sprints[sprint.id] else 0



      averageSeries = { name: assignee.name, data: averageAssignees, lineWidth: 0.5, color:"gray", marker: { radius: 2, lineColor: "#DFDFDF" }, type: 'line'}
      stdDeviationAndMean = calcStandardDeviation(averageAssignees)
      showControlChart("here", "Team velocity control chart", sprintCategories, "velocity", stdDeviationAndMean.mean, stdDeviationAndMean.standardDeviation, averageSeries, assigneeSeries)

    )

  )
  this