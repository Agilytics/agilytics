module.directive('assigneeSummary', [ "$http", "$timeout", ($http, $timeout) ->

  showGraph = (assignees, boards, options, scope)=>
      # options { days, board }

      if(options.days)
        d = new Date
        time = d.setDate(d.getDate() - options.days)

      # filter on a specific board
      thereIsABoardFilter = !!options.board
      thereIsNoBoardFilter =  !thereIsABoardFilter

      if(thereIsABoardFilter)
        newBoards = []
        newBoards.push board for board in boards when board.jid == options.board.jid
        boards = newBoards

      seriesObj = { series: [], boardSeries: {} }
      _.each(boards,(b, i)->
          seriesObj.boardSeries[b.jid] =
                                  name: b.name
                                  data: []
          seriesObj.series.push seriesObj.boardSeries[b.jid]
      )


      _.each( assignees, (assignee)->
        filteredVelocities = []
        if(d)
          filteredVelocities = _.filter(assignee.velocities, (v)->
                        v.sprintStartDate >= time &&
                        ( thereIsNoBoardFilter ||  v.boardId == options.board.jid )
          )
        else
          filteredVelocities = _.filter(assignee.velocities, (v)->
            ( thereIsNoBoardFilter ||  v.boardId == options.board.jid )
          )


        assignee.boardVelocities = {}
        assignee.velocity = 0

        sum = (memo, velocity)-> memo + velocity.velocity

        groupedFilteredVelocities = _.groupBy( filteredVelocities, (fv) -> fv.boardId )

        _.each(groupedFilteredVelocities, (velocities, boardId) ->

            boardVelocity = _.reduce(velocities, sum, 0)

            assignee.boardVelocities[boardId] = boardVelocity

            assignee.velocity += boardVelocity
        )
      )


      assignees = _.sortBy(assignees, (a)-> a.velocity * -1 )

      categories = []

      scope.assigneesLength = 0
      _.each(assignees, (assignee)->

        if assignee.velocity
          scope.assigneesLength += 1
          _.each(seriesObj.boardSeries, (bs, boardId)->
            bs.data.push assignee.boardVelocities[boardId] || 0
          )

          categories.push assignee.name
      )


      series = seriesObj.series
      addBoardTitle = ""
      if(thereIsABoardFilter)
        addBoardTitle = " for board ( #{options.board.name} )"

      _showGraph = (boardId, series, categories, addBoardTitle)->

        $("#assignees-graph-" + boardId).highcharts
          chart:
            type: "bar"

          title:
            text: "Assignees " + addBoardTitle

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

      sg = -> _showGraph(scope.boardId, series, categories, addBoardTitle)
      $timeout(sg, 0)

  init = (scope)->
    scope.headers = [
        "Assignee Name",
        "Completed Story Points (Velocity)"
    ]

    scope.boardId = if scope.board then scope.board.jid else "no-board"

    assigneeRows = []

    _.each(scope.assignees, (assignee)->
      cols = []
      cols.push assignee.name
      sum = (memo, velocity)-> memo + velocity.velocity
      cols.push _.reduce(assignee.velocities, sum, 0)
      assigneeRows.push cols
    )

    scope.filter = (days)=>
          scope.days = days
          console.log(scope.days)
          showGraph( scope.assignees, scope.boards, { days: days, board: scope.board }, scope )

    scope.assigneeRows = assigneeRows
    showGraph( scope.assignees, scope.boards, { board: scope.board }, scope )


  restrict: 'E'
  link: (scope, element, attr) ->
          init(scope)
          this
  scope:
      boards: "="
      assignees: "="
      board: "="

  templateUrl: "/assets/directives/assigneeSummary.html"
])
