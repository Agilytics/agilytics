angular.module('agilytics').directive('boardSummaryTrendLine', [ "$http", "$timeout", ($http, $timeout) ->

  init = (scope)->
    @colors = scope.colors ||   {}
    scope.sprintRows = []
    scope.headers = [
        "Sprint Name",
        "Start Date",
        "Commitment",
        "Total Work",
        "Committed Velocity",
        "Total Velocity"
        "Removed Commitment"
        "Removed Added"
    ]

  showGraph = (boardId, sprints, boardName, currentSprint)=>

    series = [
                name: "Removed Added"
                color: @colors.removedAdded || "purple"
                data: []
              ,
                name: "Missed Added"
                color: @colors.missedAdded || "purple"
                data: []
              ,
                name: "Removed Committed"
                color: @colors.removedCommitted || "purple"
                data: []
              ,
                name: "Missed Commitment"
                color: @colors.missedCommitted || "purple"
                data: []
              ,
                name: "Added"
                color: @colors.addedVelocity || "purple"
                data: []
              ,
                name: "Changed"
                color: @colors.changedVelocity || "purple"
                data: []
              ,
                name: "Committed"
                color: @colors.committedVelocity || "purple"
                data: []
              ,
                name: "Total Velocity"
                color: @colors.totalVelocity || "purple"
                data: []

            ]

    categories = []

    sprintHadSomeActivity = (sprint)-> !!(sprint.totalCommitment || sprint.addedVelocity || sprint.estimateChangedVelocity || sprint.initVelocity)
    count = 0
    for sprint in sprints when sprintHadSomeActivity(sprint)

        series[0].data.push { y: sprint.removedAddedVelocity || 0, sprintId: sprint.pid }
        series[1].data.push { y: sprint.missedAddedCommitment - sprint.removedAddedVelocity, sprintId: sprint.pid }
        series[2].data.push { y: sprint.removedCommittedVelocity || 0, sprintId: sprint.pid }
        series[3].data.push { y: sprint.missedInitCommitment - sprint.removedCommittedVelocity, sprintId: sprint.pid }
        series[4].data.push { y: sprint.addedVelocity, sprintId: sprint.pid }
        series[5].data.push { y: sprint.estimateChangedVelocity, sprintId: sprint.pid }
        series[6].data.push { y: sprint.initVelocity, sprintId: sprint.pid }
        series[7].data.push { y: sprint.totalVelocity, sprintId: sprint.pid }
        categories.push sprint.name
        if currentSprint && currentSprint == sprint
          sprintNumber = count
        count++


    categories.push 'Sprint 15'

    highchartsOptions =
      chart:
        type: "line"
        renderTo: "#{boardId}-sprints-graph"

      title:
        text: boardName + " : sprint velocities"

      xAxis:
        categories: categories

      tooltip:
        enabled: true
        formatter: -> "#{this.y} "

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
        line:
          marker:
            symbol: "circle"
            states:
              hover:
                radius: 4
                enabled: true
            enabled: false

          point:
            events:
              click: ->
                window.location.hash = "/sprints/#{this.options.sprintId}"

      series: series

    highchartsOptions.plotOptions.series.animation = false if currentSprint

    # current sprint vertical marker
    if currentSprint
      highchartsOptions.xAxis.plotLines = [
              value: sprintNumber
              width: 4
              color: '#DDD'
              label:
                  text: currentSprint.name
      ]

    new Highcharts.Chart highchartsOptions

  processSprint = (sprint, scope)->

    startDate = new Date(sprint.startDate)
    month = startDate.getMonth() + 1
    year =  startDate.getFullYear()
    date =  startDate.getDate()
    cols = []
    cols.push "#{sprint.name}"
    cols.push "#{month}/#{date}/#{year}"
    cols.push "#{sprint.initCommitment}"
    cols.push "#{sprint.totalCommitment}"
    cols.push "#{sprint.initVelocity}"
    cols.push "#{sprint.totalVelocity}"
    cols.push "#{sprint.removedAddedVelocity}"
    cols.push "#{sprint.removedCommittedVelocity}"

    scope.sprintRows.push({ pid: sprint.pid, cols: cols })

  linker = (scope, element, attrs) ->

    scope.$watch("board.sprints", ->

      if(scope.board && scope.board.sprints)

        init(scope)
        sprints = scope.board.sprints

        scope.height = scope.$eval(attrs['graphHeight']) || 500

        for sprint in sprints when !scope.sprint || scope.sprint == sprint
          processSprint sprint, scope

        sg = -> showGraph( scope.board.pid, sprints, scope.board.name, scope.sprint )
        $timeout(sg, 0)

      scope.goToBoard = =>
        window.location = "#/boards/" + scope.board.pid

      scope.filter = -> showGraph(scope.board.pid, sprints)
    )

    this

  restrict: 'E',
  link: linker,
  templateUrl: "views/directives/board_summary_trend_line.html"
  scope:
      board: "="
      sprint: "="
      colors: "="
])
