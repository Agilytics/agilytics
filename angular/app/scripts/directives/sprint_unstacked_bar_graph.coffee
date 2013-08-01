angular.module('agilytics').directive('sprintUnstackedBarGraph', [ "$http", "$timeout", ($http, $timeout) ->

  showGraph = (sprint, scope)=>
    scope.colors = {} unless scope.colors
    series = [
                name: "Removed Added"
                color: scope.colors.removedAdded || "purple"
                data: [{ y: sprint.removedAddedVelocity || 0 }]
              ,
                name: "Missed Added"
                color: scope.colors.missedAdded || "purple"
                data: [{ y: sprint.missedAddedCommitment - sprint.removedAddedVelocity }]
              ,
                name: "Removed Committed"
                color: scope.colors.removedCommitted || "purple"
                data: [{ y: sprint.removedCommittedVelocity || 0 }]
              ,
                name: "Missed Commitment"
                color: scope.colors.missedCommitted || "purple"
                data: [{ y: sprint.missedInitCommitment - sprint.removedCommittedVelocity }]
              ,
                name: "Added Velocity"
                color: scope.colors.addedVelocity || "purple"
                data: [{ y: sprint.addedVelocity }]
              ,
                name: "Velocity Changed"
                color: scope.colors.changedVelocity || "purple"
                data: [{ y: sprint.estimateChangedVelocity }]
              ,
                name: "Vecocity Committed"
                color: scope.colors.committedVelocity || "purple"
                data: [{ y: sprint.initVelocity }]
              ,
                name: "Total Velocity"
                color: scope.colors.totalVelocity || "purple"
                data: [{ y: sprint.totalVelocity }]
            ]

    series = _.filter(series, (s)->s.data[0].y)
    scope.seriesCount = series.length

    highchartsOptions =
      chart:
        type: "bar"

      title:
        text:  "#{sprint.name} "

      tooltip:
        enabled: true
        formatter: -> "#{this.series.name}: points: #{this.y}"
      xAxis:
        labels:
          enabled: false
      yAxis:
        min: 0
        title:
          text: "Story Points"

      legend:
        backgroundColor: "#FFFFFF"
        reversed: true

      plotOptions:
        series:
          cursor: 'pointer'

      series: series

    highchartsOptions.plotOptions.series.animation = false

    sg = -> $("#" + sprint.pid + "-sprints-unstacked-bar-graph").highcharts highchartsOptions
    $timeout(sg, 0)

  linker = (scope, element, attr) ->

    scope.$watch "sprint", ->

      showGraph(scope.sprint, scope) if scope.sprint

    this

  restrict: 'E',
  link: linker,
  templateUrl: "views/directives/sprint_unstacked_bar_graph.html"
  scope:
      sprint: "="
      colors: "="
])
