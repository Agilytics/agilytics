angular.module('agilytics').directive('releaseAndCosts', [ "$http", "$rootScope", "$timeout", "boardDataService",
  ($http, $rootScope, $timeout, boardDataService) ->


    showReleaseGraph = (id, title, yAxisText, series)=>
      $("\##{id}").highcharts
        chart:
          type: "area"

        title:
          text: title

        xAxis:
          type: 'datetime',

          title:
            text: 'Date'

        yAxis:
          title:
            text: yAxisText

          labels:
            formatter: ->
              @value

        tooltip:
          formatter: ->
            "#{this.point.name} : storyPoints #{this.point.y} Date: #{this.point.date} <br/> #{this.point.detail}"

        series: series

    makePoint = (event, y) ->
        d = new Date(event.date)
        date = (d.getMonth() + 1) + '/' + d.getDate() + '/' + d.getFullYear()

        format2 = (n) ->
          if n
            "$#{n.toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, "$1,")}"

        name = event.event.name

        detail = ''
        if event.type == 'release'
          release = event.event

          for sprint in event.event.sprints
            detail += "<br>#{sprint.name} #{format2(sprint.cost)} velocity: #{sprint.total_velocity || 0}"

          detail = "Total: #{format2 release.calculated_cost} velocity: #{release.total_velocity} <br/>" + detail
          name = "Release: #{name}"
        else
          sprint = event.event
          detail += "<br>#{sprint.name} #{format2(sprint.cost)} velocity: #{sprint.total_velocity || 0}"

        name: name,
        x: event.date,
        y: y
        date: date
        detail: detail

    linker = (scope)=>

      @boardId = scope.board.id

      #null is eventRange
      boardDataService.getEvents @boardId, $rootScope.siteId, null, (res)=>

        @sprints = res.sprints
        @releases = res.releases
        @board = res.board
        events = res.events

        # story points
        summedDeadVelocityBySprint = []
        summedDeadVelocity = 0
        releasedVelocity = []
        sprintVelocity = []

        # $
        summedDeadVelocityCostBySprint = []
        summedDeadVelocityCost = 0
        releasedVelocityCost = []
        sprintVelocityCost = []


        for event in events

          if event.type == "sprint"

            sprint = event.event
            # story points
            summedDeadVelocity -= sprint.total_velocity

            sprintVelocity.push makePoint event, -1 * sprint.total_velocity

            # $
            summedDeadVelocityCost -= sprint.cost
            sprintVelocityCost.push makePoint event, -1 * sprint.cost

            summedDeadVelocityCostBySprint.push makePoint event, summedDeadVelocityCost
            summedDeadVelocityBySprint.push makePoint event, summedDeadVelocity

          else
            release = event.event
            # story points
            summedDeadVelocity += release.total_velocity

            releasedVelocity.push makePoint event, release.total_velocity
            summedDeadVelocityBySprint.push makePoint event, summedDeadVelocity

            # $
            summedDeadVelocityCost += release.calculated_cost
            summedDeadVelocityCostBySprint.push makePoint event, summedDeadVelocityCost
            releasedVelocityCost.push makePoint event, release.calculated_cost

        # story points
        releasedVelocitySeries = { name: "Release Velocity", data: releasedVelocity, color: "#99CC99", type: "column", pointWidth: 30 }
        deadVelocitySeries = { name: "Dead Velocity Cost", data: summedDeadVelocityBySprint, color: "#FF9999" }
        sprintVelocitySeries = { name: "Sprint Cost", data: sprintVelocity, color: "#FF6666", type: "column", borderWidth: 0 }

        # $
        releasedVelocityCostSeries = { name: "Release Velocity", data: releasedVelocityCost, color: "#99CC99", type: "column", pointWidth: 30 }
        deadVelocityCostSeries = { name: "Dead Velocity Cost", data: summedDeadVelocityCostBySprint, color: "#FF9999" }
        sprintVelocityCostSeries = { name: "Sprint Cost", data: sprintVelocityCost, color: "#FF6666", type: "column", borderWidth: 0 }

        showReleaseGraph("releaseVelocityChart", "Dead & Realized Velocity", "Story Points",
          [releasedVelocitySeries, deadVelocitySeries, sprintVelocitySeries])
        showReleaseGraph("releaseChart", "Velocity, cost & releases", "Cost in $",
          [releasedVelocityCostSeries, deadVelocityCostSeries, sprintVelocityCostSeries])
      @

    restrict: 'E'
    link: linker
    templateUrl: "views/directives/release_and_costs.html"
    scope:
      board: "="
  ])