angular.module('agilytics').directive('releaseAndCosts',
  [ "$http", "$rootScope", "$timeout", ($http, $rootScope, $timeout) ->
    getReleases = (callback) =>
      $http.get("/api/releases.json?board_id=#{@boardId}&site_id=#{$rootScope.siteId}").success((releases)=>
        for release in releases
          calculateReleaseCost(release)
          @releases.push release
        callback()
      )

    calculateReleaseCost = (release)=>
      release.calculated_cost = 0
      releaseSprints = []

      for sprint in release.sprints
        locSprint = @sprintsByKey[sprint.pid]

        if locSprint
          release.total_velocity += locSprint.total_velocity*1
        else
          locSprint = sprint.cost
          locSprint = sprint

        release.calculated_cost += locSprint.cost
        releaseSprints.push locSprint

      release.sprints.length = 0
      release.sprints.push releaseSprints

    calculateCosts = =>
      @unreleased_sprint_costs = 0
      for sprint in @sprints
        calculateCost sprint

    calculateCost = (sprint)=>
      unless(sprint.cost)
        sprint.cost = @board.run_rate_cost

    getSprintsForBoard = (callback)=>
      $http.get("/api/boards/#{@board.id}/stats.json?site_id=#{$rootScope.siteId}").success((res)=>

        for sprint in res.data
          @sprints.push sprint

          @sprintsByKey[sprint.pid] = sprint
          calculateCosts()
        callback()
      )

    showReleaseGraph = (id, title, yAxisText,  series)=>

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

    linker = (scope, element, attr) =>
      @boardId = scope.board.id
      $http.get("/api/boards/#{@boardId}/stats.json?site_id=#{$rootScope.siteId}").success (res)->

        @board = res.board
        @sprints = []
        @sprintsByKey = {}
        @releases = []

        callback = =>

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

          events = []

          makeUTC = (date)->
            dateObj = new Date(date)
            Date.UTC(dateObj.getUTCFullYear(),  dateObj.getUTCMonth(), dateObj.getUTCDate())

          for sprint in @sprints when new Date(sprint.end_date)
            events.push { date: makeUTC(sprint.end_date), event: sprint, type: "sprint" }

          for release in @releases when new Date(release.release_date)
            events.push { date: makeUTC(release.release_date), event: release, type: "release" }

          events = _.sortBy(events, (s)-> new Date(s.date))

          makePoint = (event, y) ->
            d = new Date(event.date)
            date = (d.getMonth() + 1) + '/' + d.getDate() + '/' +  d.getFullYear()

            format2 = (n) ->
              if n
                "$#{n.toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, "$1,")}"

            name = event.event.name

            detail = ''
            if event.type == 'release'
              for sprint in event.event.sprints
                detail += "<br>#{sprint.name} #{format2(sprint.cost)} velocity: #{sprint.total_velocity || 0}"

              detail = "Total: #{format2 release.calculated_cost} velocity: #{release.total_velocity} <br/>"  + detail
              name = "Release: #{name}"
            else
              detail += "<br>#{sprint.name} #{format2(sprint.cost)} velocity: #{sprint.total_velocity || 0}"

            name: name,
            x: event.date,
            y: y
            date: date
            detail: detail

          for event in events

            if event.type == "sprint"
              sprint = event.event
              # story points
              summedDeadVelocity -= sprint.total_velocity
              sprintVelocity.push  makePoint event,  -1 * sprint.total_velocity

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
              # $                                                            yep
              summedDeadVelocityCost += release.calculated_cost
              summedDeadVelocityCostBySprint.push makePoint event, summedDeadVelocityCost
              releasedVelocityCost.push makePoint event, release.calculated_cost


          # story points
          releasedVelocitySeries = { name: "Release Velocity", data: releasedVelocity , color: "#99CC99", type: "column", pointWidth: 30 }
          deadVelocitySeries = { name: "Dead Velocity Cost", data: summedDeadVelocityBySprint, color: "#FF9999" }
          sprintVelocitySeries = { name: "Sprint Cost", data: sprintVelocity , color: "#FF6666", type: "column", borderWidth: 0 }

          # $
          releasedVelocityCostSeries = { name: "Release Velocity", data: releasedVelocityCost , color: "#99CC99", type: "column", pointWidth: 30 }
          deadVelocityCostSeries = { name: "Dead Velocity Cost", data: summedDeadVelocityCostBySprint, color: "#FF9999" }
          sprintVelocityCostSeries = { name: "Sprint Cost", data: sprintVelocityCost , color: "#FF6666", type: "column", borderWidth: 0 }

          showReleaseGraph("releaseVelocityChart", "Dead & Realized Velocity", "Story Points",  [releasedVelocitySeries, deadVelocitySeries, sprintVelocitySeries])
          showReleaseGraph("releaseChart", "Velocity, cost & releases", "Cost in $",  [releasedVelocityCostSeries, deadVelocityCostSeries, sprintVelocityCostSeries])

        getSprintsForBoard -> getReleases callback

      @

    restrict: 'E',
    link: linker,
    templateUrl: "views/directives/release_and_costs.html"
    scope:
      board: "="

  ])