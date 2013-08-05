angular.module('agilytics').directive('assigneeBoardSummary', [ "$http", "$timeout", ($http, $timeout) ->

  showGraph = (assignees, boards, options, scope)=>
      # options { days, board }

      if(options.days)
        dateFilter = new Date(scope.enddatetime)
        dateTimeFilter = new Date(dateFilter.setDate(dateFilter.getDate() - options.days))

      # filter on a specific board
      thereIsABoardFilter = !!options.board
      thereIsNoBoardFilter =  !thereIsABoardFilter

      if(thereIsABoardFilter)
        scope.spanWidth = "span11"
        newBoards = []
        newBoards.push board for board in boards when board.pid == options.board.pid
        boards = newBoards
      else
        scope.spanWidth = "span6"

      seriesObj = { series: [], seriesBoardWork: [], boardSeries: {}, workSeries: {} }

      _.each(boards,(b)->
          seriesObj.boardSeries[b.pid] =
                                  name: b.name
                                  data: []

          seriesObj.workSeries[b.pid] =
                                  name: b.name
                                  data: []

          seriesObj.series.push seriesObj.boardSeries[b.pid]
          seriesObj.seriesBoardWork.push seriesObj.workSeries[b.pid]

      )

      _.each( assignees, (assignee)->

        filteredWorkActivities = []
        if(dateFilter)
          filteredWorkActivities = _.filter(assignee.workActivities,
            (v)->
                filter = new Date(v.sprint.startDate) >= dateTimeFilter &&
                ( thereIsNoBoardFilter ||  v.board.pid == options.board.pid )

                filter
          )
        else
          filteredWorkActivities = _.filter(assignee.workActivities, (v)->
            ( thereIsNoBoardFilter ||  v.board.pid == options.board.pid )
          )


        assignee.boardVelocities = {}
        assignee.velocity = 0

        assignee.relativeBoardVelocities = {}


        sum = (memo, velocity)-> memo + velocity.storyPoints

        groupedFilteredWorkActivities = _.groupBy( filteredWorkActivities, (fwa) -> fwa.board.pid )

        _.each(groupedFilteredWorkActivities, (workActivities, boardId) ->

            boardVelocity = _.reduce(workActivities, sum, 0)

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
            hchartsObj =
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
                  color: "#BABABA"

              series: series

            delete hchartsObj.plotOptions.series.color unless thereIsABoardFilter
            $(id).highcharts hchartsObj

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
        cols.push _.reduce(assignee.workActivities, sum, 0)
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

    scope.boardId = if scope.board then scope.board.pid else "no-board"

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
      enddatetime: "="

  templateUrl: "views/directives/assignee_board_summary.html"
])
