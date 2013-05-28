module.directive('boardSummary', [ "$http", "$timeout", ($http, $timeout) ->

  init = (scope)->
    scope.sprintRows = []
    scope.headers = [
        "Sprint Name",
        "Start Date",
        "Initial Commitment",
        "Total Commitment",
        "Initial Velocity",
        "Total Velocity"
      ]

  showGraph = (boardId, sprints, boardName)=>

    series = [
                name: "Missed"
                color: "#fad2d2"
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

    sprintHadSomeActivity = (sprint)-> sprint.totalCommitment || sprint.addedVelocity || sprint.estimateChangedVelocity || sprint.initVelocity

    for sprint in sprints when sprintHadSomeActivity(sprint)
        series[0].data.push sprint.totalCommitment - sprint.totalVelocity
        series[1].data.push sprint.addedVelocity
        series[2].data.push sprint.estimateChangedVelocity
        series[3].data.push sprint.initVelocity

        categories.push sprint.name

    $("#" + boardId + "-sprints-graph").highcharts
      chart:
        type: "bar"

      title:
        text: boardName + " : sprint velocities"

      xAxis:
        categories: categories

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

      series: series

  processSprint = (sprint, scope)->

    startDate = new Date(sprint.change_set.startTime)
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

    scope.sprintRows.push(cols)

  linker = (scope, element, attr) ->

    sprints = scope.board.sprints

    init(scope)

    if(sprints)
      for sprint in sprints
        processSprint sprint, scope

      sg = -> showGraph( scope.board.jid, sprints, scope.board.name )
      $timeout(sg, 0)

    scope.filter = -> showGraph(scope.board.jid, sprints)

    this

  restrict: 'E',
  link: linker,
  templateUrl: "/assets/directives/boardSummary.html"
  scope:
      board: "="

])
