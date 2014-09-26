class @BoardService
  constructor: (@$http, @agiliticsUtils)->

  _calculateSprintCost: (sprint, board)=>
    unless(sprint.cost)
      sprint.cost = board.run_rate_cost

  _calculateReleaseCost: (release)=>
    release.calculated_cost = 0
    releaseSprints = []

    # when is due to the possibility that the release may be filtered
    for sprint in release.sprints when @filteredSprintsByKey[sprint.pid]
      locSprint = @filteredSprintsByKey[sprint.pid]

      if locSprint
        release.total_velocity += locSprint.total_velocity * 1
      else
        locSprint = sprint.cost
        locSprint = sprint

      release.calculated_cost += locSprint.cost
      releaseSprints.push locSprint


    release.sprints.length = 0
    release.sprints.push releaseSprints

  getEvents: (boardId, siteId, eventRange, callback)=>

    @filteredSprintsByKey = {}
    releases = []
    loc_eventRange = {}
    eventRange = {} unless eventRange

    @$http.get("/api/releases.json?board_id=#{boardId}&site_id=#{siteId}").success (releases)=>

      @$http.get("/api/boards/#{boardId}/stats.json?site_id=#{siteId}").success (res)=>

        board = res.board

        sprintVelocityCostStats = res.data
        filteredSprintVelocityCostsStats = []

        startWithThisEvent = if sprintVelocityCostStats.length - 10 > 0 then sprintVelocityCostStats.length - 10 else 0
        eventRange.from = sprintVelocityCostStats[startWithThisEvent].pid if sprintVelocityCostStats && !eventRange.from

        if !eventRange.to ||  eventRange.to == sprintVelocityCostStats[sprintVelocityCostStats.length - 1].pid
          eventRange.doNotFilterEnd = true
          eventRange.to = sprintVelocityCostStats[sprintVelocityCostStats.length - 1].pid

        events = []
        sprintEvents = []
        releaseEvents = []
        #
        filteredEvents = []
        filteredSprintEvents = []
        filteredReleaseEvents = []

        beginIncludingSprints = false
        stopIncludingSprints = false

        for sprint in sprintVelocityCostStats

          @_calculateSprintCost sprint, board

          d = @agiliticsUtils.makeUTCObject(sprint.end_date)
          sprintEvent = { date: d.utc, dateString: d.str, event: sprint, type: "sprint" }

          ## filtering
          beginIncludingSprints = beginIncludingSprints || sprint.pid == eventRange.from

          if beginIncludingSprints && !stopIncludingSprints
            @filteredSprintsByKey[sprint.pid] = sprint
            filteredSprintVelocityCostsStats.push sprint
            filteredEvents.push sprintEvent
            filteredSprintEvents.push sprintEvent


          stopIncludingSprints = stopIncludingSprints || sprint.pid == eventRange.to
          ## end filtering

          events.push sprintEvent
          sprintEvents.push sprintEvent

          loc_eventRange.from = sprintEvent if sprint.pid == eventRange.from
          loc_eventRange.to = sprintEvent if sprint.pid == eventRange.to



        for release in releases
          @_calculateReleaseCost(release)
          d = @agiliticsUtils.makeUTCObject(release.release_date)
          releaseEvent = { date: d.utc, dateString: d.str, event: release, type: "release" }

          events.push releaseEvent
          releaseEvents.push releaseEvent
          if d.utc >= loc_eventRange.from.date && ( d.utc <= loc_eventRange.to.date || eventRange.doNotFilterEnd )
            filteredEvents.push releaseEvent
            filteredReleaseEvents.push releaseEvent

        sortByDate = (events)-> _.sortBy(events, (s)-> s.date )

        callback
          board: res.board
          #
          events: sortByDate events
          filteredEvents: sortByDate filteredEvents
          filteredSprintEvents: sortByDate filteredSprintEvents
          filteredReleaseEvents: sortByDate filteredReleaseEvents
          releaseEvents: sortByDate releaseEvents
          sprintEvents: sortByDate sprintEvents
          #
          eventRange: loc_eventRange
          releases: releases
          sprints: sprintVelocityCostStats
          filteredSprintsByKey: @filteredSprintsByKey
          stats: sprintVelocityCostStats
          filteredStats: filteredSprintVelocityCostsStats
          seriesData: @createSeriesForGraphs(sprintVelocityCostStats, res.board.categories)
          filteredSeriesData: @createSeriesForGraphs(filteredSprintVelocityCostsStats, res.board.categories)

  createSeriesForGraphs: (data, categories)=>

    # colors: http://coolmaxhot.com/graphics/hex-color-palette.htm
    buildSeries = (withTotal)->
      ret = []
      ret.push { name: "total", data: [], color: '#666', lineWidth: 0.5, marker: { radius: 2, lineColor: "#DFDFDF" }, type: 'line'} if withTotal
      for category in categories
        ret.push { name: category.name, data: [] }
      ret

    sprints = []

    counts = {}
    counts.series = buildSeries(true)
    counts.seriesPercent = buildSeries()

    velocities = {}
    velocities.series = buildSeries(true)
    velocities.seriesPercent = buildSeries()

    for stat in data
      sprints.push stat.sprint_name.replace('Sprint', '  ')
      totalCount = 0
      totalVelocity = 0

      for cat, i in categories
        count = stat["cat_#{cat.id}_count"] * 1

        stat["cat_#{cat.id}_percentage_count"] = @agiliticsUtils.toPercent stat["cat_#{cat.id}_percentage_count"]
        percent_count = stat["cat_#{cat.id}_percentage_count"] * 1

        velocity = stat["cat_#{cat.id}_velocity"] * 1
        stat["cat_#{cat.id}_percentage_velocity"] = @agiliticsUtils.toPercent stat["cat_#{cat.id}_percentage_velocity"] * 1
        percent_velocity = stat["cat_#{cat.id}_percentage_velocity"] * 1

        totalCount += count
        counts.series[i + 1].data.push count
        counts.seriesPercent[i].data.push percent_count

        totalVelocity += velocity
        velocities.series[i + 1].data.push velocity
        velocities.seriesPercent[i].data.push percent_velocity

      counts.series[0].data.push totalCount
      velocities.series[0].data.push totalVelocity

    sprints: sprints
    counts: counts
    velocities: velocities

  save: (boardId, siteId, data, callback) =>
    @$http(
      url: "/api/boards/#{boardId}/update.json?siteId=#{siteId}"
      method: "POST"
      data: JSON.stringify(data)
      headers: {'Content-Type': 'application/json'}
    ).success((data, status, headers, config) ->
      callback(data)
    ).error((data, status, headers, config) ->
      alert 'error'
    )

  deleteCategory: (boardId, siteId, categoryId, callback) =>
    @$http(
      url: "/api/boards/#{boardId}/deleteCategory.json?siteId=#{siteId}&category_id=#{categoryId}"
      method: "POST"
      headers: {'Content-Type': 'application/json'}
    ).success((data, status, headers, config) ->
      callback(data)
    ).error((data, status, headers, config) ->
      alert 'error'
    )

  getTags: (boardId, siteId, callback) =>
    @$http.get("/api/boards/#{boardId}/tags.json?site_id=#{siteId}").success (res)=>
      callback(res.tags)

  getCategories: (boardId, siteId, callback) =>
    @$http.get("/api/boards/#{boardId}/categories.json?site_id=#{siteId}").success (res)=>
      callback(res.categories)


  saveCategories: (boardId, siteId, categories, callback)=>
    data = {
      categories: categories
    }

    @$http(
      url: "/api/boards/#{boardId}/setCategories.json?siteId=#{siteId}"
      method: "POST"
      data: JSON.stringify(data)
      headers: {'Content-Type': 'application/json'}
    ).success((data, status, headers, config) ->
      callback(data)
    ).error((data, status, headers, config) ->
      alert 'error'
    )

angular.module('agilytics').factory('boardDataService', ["$http", "agiliticsUtils", ($http, agiliticsUtils)->
  new BoardService($http, agiliticsUtils)
])