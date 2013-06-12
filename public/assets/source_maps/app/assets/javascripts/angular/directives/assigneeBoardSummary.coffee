module.directive('assigneeBoardSummary', [ "$http", "$timeout", ($http, $timeout) ->

  showGraph = (assignees, boards, options, scope)=>
      # options { days, board }

      if(options.days)
        dateFilter = new Date
        time = dateFilter.setDate(dateFilter.getDate() - options.days)

      # filter on a specific board
      thereIsABoardFilter = !!options.board
      thereIsNoBoardFilter =  !thereIsABoardFilter


      if(thereIsABoardFilter)
        scope.spanWidth = "span12"
        newBoards = []
        newBoards.push board for board in boards when board.jid == options.board.jid
        boards = newBoards
      else
        scope.spanWidth = "span6"

      seriesObj = { series: [], seriesBoardWork: [], boardSeries: {}, workSeries: {} }

      _.each(boards,(b)->
          seriesObj.boardSeries[b.jid] =
                                  name: b.name
                                  data: []

          seriesObj.workSeries[b.jid] =
                                  name: b.name
                                  data: []

          seriesObj.series.push seriesObj.boardSeries[b.jid]
          seriesObj.seriesBoardWork.push seriesObj.workSeries[b.jid]

      )

      _.each( assignees, (assignee)->
        filteredVelocities = []
        if(dateFilter)
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

        assignee.relativeBoardVelocities = {}


        sum = (memo, velocity)-> memo + velocity.velocity

        groupedFilteredVelocities = _.groupBy( filteredVelocities, (fv) -> fv.boardId )

        _.each(groupedFilteredVelocities, (velocities, boardId) ->

            boardVelocity = _.reduce(velocities, sum, 0)

            assignee.boardVelocities[boardId] = boardVelocity

            assignee.velocity += boardVelocity
        )

      )



      assigneesWithVelocity = _.filter(assignees, (a)-> a.velocity )
      scope.assigneesLength = assigneesWithVelocity.length


      buildCategories = (assignees, series, destSeriesObj, calcDestValue )->
        categories = []

        _.each(assignees, (assignee)->

            _.each(destSeriesObj, (boardSeries, boardId)->
              boardVelocity = assignee.boardVelocities[boardId] || 0
              v = calcDestValue( boardVelocity, assignee )
              boardSeries.data.push v
            )

            categories.push assignee.name
        )
        categories

      assigneesWithVelocitySortedByVelocity = _.sortBy(assigneesWithVelocity, (assignee)-> assignee.velocity * -1 )
      categoriesByVelocity = buildCategories(assigneesWithVelocitySortedByVelocity,
                                              seriesObj.series,
                                              seriesObj.boardSeries ,
                                              (v)-> v )

      assigneesWithVelocitySortedByNumberOfBoards = _.sortBy(assigneesWithVelocitySortedByVelocity, (assignee) ->
        count = 0
        _.each(assignee.boardVelocities, (hasVelocity)-> count += 1 if hasVelocity )
        count * -1
      )

      categoriesByBoards = buildCategories(assigneesWithVelocitySortedByNumberOfBoards,
                                            seriesObj.seriesBoardWork,
                                            seriesObj.workSeries,
                                            (velocity, assignee)-> 100 * velocity / assignee.velocity )

      addBoardTitle = ""
      if(thereIsABoardFilter)
        addBoardTitle = " for board ( #{options.board.name} )"

      _showGraph = (id, series, categories, title, yAxisLabel) ->

          if(!series.length || !series[0].data.length)
            $(id).html("<br><h4>No data</h4>")
          else
            $(id).highcharts
              chart:
                type: "bar"

              title:
                text: title

              xAxis:
                categories: categories

              yAxis:
                title:
                  text: yAxisLabel
                minPadding: 0.0
                maxPadding: 0.0
                endOnTick: true

              legend:
                backgroundColor: "#FFFFFF"
                reversed: true

              plotOptions:
                series:
                  stacking: "normal"

              series: series

      sg = ->
          _showGraph("#assignees-velocities-graph-" + scope.boardId, seriesObj.series, categoriesByVelocity, "Assignees velocity" + addBoardTitle, "Story Points")
          unless thereIsABoardFilter
            _showGraph("#assignees-work-graph-" + scope.boardId, seriesObj.seriesBoardWork, categoriesByBoards, "Assignees by Board/Project", "% of work per board")
          else
            $("#assignees-work-graph-" + scope.boardId).remove()

      $timeout(sg, 0)

  processAssignees = (scope)->
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
            showGraph( scope.assignees, scope.boards, { days: days, board: scope.board }, scope )

      scope.assigneeRows = assigneeRows
      showGraph( scope.assignees, scope.boards, { board: scope.board }, scope )

  init = (scope)->
    scope.headers = [
        "Assignee Name",
        "Completed Story Points (Velocity)"
    ]

    scope.boardId = if scope.board then scope.board.jid else "no-board"

    if scope.assignees
      processAssignees(scope)

    scope.$watch("assignees", -> processAssignees(scope))


  restrict: 'E'
  link: (scope, element, attr) ->
          init(scope)
          this
  scope:
      boards: "="
      assignees: "="
      board: "="

  templateUrl: "/assets/directives/assigneeBoardSummary.html"
])
