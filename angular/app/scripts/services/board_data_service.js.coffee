class @BoardService
  constructor: (@$http, @agiliticsUtils)->

  _calculateSprintCost: (sprint, board)=>
    unless(sprint.cost)
      sprint.cost = board.run_rate_cost

  _calculateReleaseCost: (release)=>
    release.calculated_cost = 0
    releaseSprints = []

    for sprint in release.sprints
      locSprint = @sprintsByKey[sprint.pid]

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

    @sprintsByKey = {}
    loc_releases = []

    @$http.get("/api/releases.json?board_id=#{boardId}&site_id=#{siteId}").success (releases)=>
      loc_releases = []
      loc_eventRange = {}



      @$http.get("/api/boards/#{boardId}/stats.json?site_id=#{siteId}").success (res)=>

        # going to need to filter it here
        data = @processData(res.data, res.board.categories)
        stats = _.sortBy(data.stats, (s) ->
          -1 * s.id)
        board = res.board


        sprints = []
        for sprint in data.stats
          sprints.push sprint
          @sprintsByKey[sprint.pid] = sprint
          @_calculateSprintCost sprint, board

        for release in releases
          @_calculateReleaseCost(release)
          loc_releases.push release

        events = []
        sprintEvents = []
        releaseEvents = []

        makeUTC = (date)->
          dateObj = new Date(date)

          yyyy = dateObj.getUTCFullYear()
          mm = dateObj.getUTCMonth() + 1
          mm = '0' + mm if mm.length = 1
          dd = dateObj.getUTCDate()
          dd = '0' + dd if dd.length = 1

          { utc: Date.UTC(yyyy, mm, dd), str: "#{mm}/#{dd}/#{yyyy}" }

        for sprint in sprints when new Date(sprint.end_date)
          d = makeUTC(sprint.end_date)
          sprintEvent = { date: d.utc, dateString: d.str, event: sprint, type: "sprint" }
          loc_eventRange.to = sprintEvent if eventRange && eventRange.to == sprintEvent.event.pid
          loc_eventRange.from = sprintEvent if eventRange && eventRange.from == sprintEvent.event.pid
          events.push sprintEvent
          sprintEvents.push sprintEvent


        for release in loc_releases when new Date(release.release_date)
          d = makeUTC(release.release_date)
          releaseEvent = { date: d.utc, dateString: d.str, event: release, type: "release" }
          events.push releaseEvent

        sortByDate = (events)-> _.sortBy(events, (s)-> new Date(s.date))
        events = sortByDate events
        sprintEvents = sortByDate sprintEvents

        filteredEvents = []
        filteredSprintEvents = []
        filteredReleaseEvents = []

        loc_eventRange.from = sprintEvents[0] if sprintEvents && (!eventRange || !eventRange.from)
        loc_eventRange.to = sprintEvents[sprintEvents.length - 1] if sprintEvents && (!eventRange || !eventRange.to )

        begin = false
        end = false
        filteredReleaseEvents.length = 0
        filteredSprintEvents.length = 0

        for event in events
          begin = true if begin || event == loc_eventRange.from

          if begin && !end
            filteredEvents.push event
            filteredReleaseEvents.push event if event.type == "release"
            filteredSprintEvents.push event if event.type == "sprint"

          end = true if end || event == loc_eventRange.to

        callback
          board: res.board
          events: events
          filteredEvents: filteredEvents
          filteredSprintEvents: filteredSprintEvents
          filteredReleaseEvents: filteredReleaseEvents
          releaseEvents: releaseEvents
          sprintEvents: sprintEvents
          eventRange: loc_eventRange
          releases: loc_releases
          sprints: sprints
          sprintsByKey: @sprintsByKey
          stats: stats
          statsData:data

  processData: (data, categories)=>

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
    stats: data
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