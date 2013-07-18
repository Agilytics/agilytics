module.directive('boardSummary', [ "$http", "$timeout", ($http, $timeout) ->

  init = (scope)->
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

  showGraph = (boardId, sprints, boardName)=>

    series = [
                name: "Removed Added"
                color: "#FDE0B5"
                data: []
              ,
                name: "Missed Added"
                color: "#fad2d2"
                data: []
              ,
                name: "Removed Committed"
                color: "#f90"
                data: []
              ,
                name: "Missed Commitment"
                color: "#fa3939"
                data: []
              ,
                name: "Added"
                color: "black"
                data: []
              ,
                name: "Changed"
                color: "gray"
                data: []
              ,
                name: "Committed"
                color: "green"
                data: []
            ]

    categories = []

    sprintHadSomeActivity = (sprint)-> !!(sprint.totalCommitment || sprint.addedVelocity || sprint.estimateChangedVelocity || sprint.initVelocity)

    for sprint in sprints when sprintHadSomeActivity(sprint)

        series[0].data.push { y: sprint.removedAddedVelocity || 0, sprintId: sprint.pid }
        series[1].data.push { y: sprint.missedAddedCommitment - sprint.removedAddedVelocity, sprintId: sprint.pid }
        series[2].data.push { y: sprint.removedCommittedVelocity || 0, sprintId: sprint.pid }
        series[3].data.push { y: sprint.missedInitCommitment - sprint.removedCommittedVelocity, sprintId: sprint.pid }
        series[4].data.push { y: sprint.addedVelocity, sprintId: sprint.pid }
        series[5].data.push { y: sprint.estimateChangedVelocity, sprintId: sprint.pid }
        series[6].data.push { y: sprint.initVelocity, sprintId: sprint.pid }
        categories.push sprint.name

    $("#" + boardId + "-sprints-graph").highcharts
      chart:
        type: "bar"

      title:
        text: boardName + " : sprint velocities"

      xAxis:
        categories: categories

      tooltip:
        enabled: true
        formatter: -> "#{this.series.name}: points: #{this.y}"

      yAxis:
        min: 0
        title:
          text: "Story Points"

      legend:
        backgroundColor: "#FFFFFF"
        reversed: true

      plotOptions:
        series:
          stacking: "normal"
          cursor: 'pointer'
          point:
            events:
              click: ->
                window.location.hash = "/sprints/#{this.options.sprintId}"

      series: series

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

  linker = (scope, element, attr) ->

    scope.$watch("board.sprints", ->
      sprints = scope.board.sprints

      init(scope)

      if(sprints)
        for sprint in sprints
          processSprint sprint, scope

        sg = -> showGraph( scope.board.pid, sprints, scope.board.name )
        $timeout(sg, 0)

      scope.goToBoard = =>
        window.location = "#/boards/" + scope.board.pid

      scope.filter = -> showGraph(scope.board.pid, sprints)
    )

    this

  restrict: 'E',
  link: linker,
  templateUrl: "/assets/directives/board-summary.html"
  scope:
      board: "="

])
