module.directive('assigneeSummary', [ "$http", ($http) ->

  showGraph = (assignees, boards, days)=>

    if(days)
        d = new Date
        time = d.setDate(d.getDate()-days);

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
          filteredVelocities = _.filter(assignee.velocities, (v)-> v.sprintStartDate >= time )

        else
          filteredVelocities = assignee.velocities

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


      _.each(assignees, (assignee)->

        _.each(seriesObj.boardSeries, (bs, boardId)->
          bs.data.push assignee.boardVelocities[boardId] || 0
        )

        categories.push assignee.name
      )

      series = seriesObj.series

      $("#assignees-graph").highcharts
        chart:
          type: "bar"

        title:
          text: "Assignees"

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

  init = (scope)->
    scope.headers = [
        "Assignee Name",
        "Completed Story Points (Velocity)"
    ]

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
          showGraph( scope.assignees, scope.boards, days )

    scope.assigneeRows = assigneeRows
    showGraph( scope.assignees, scope.boards )


  restrict: 'E'
  link: (scope, element, attr) ->
          init(scope)
          this
  scope:
      boards: "="
      assignees: "="

  templateUrl: "/assets/directives/assigneeSummary.html"
])
