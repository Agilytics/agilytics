class @BoardService
  constructor: (@$http)->

  toPercent: (i)->
    p = Math.round(i * 100)
    p

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
        stat["cat_#{cat.id}_percentage_count"] = @toPercent stat["cat_#{cat.id}_percentage_count"]
        percent_count = stat["cat_#{cat.id}_percentage_count"] * 1

        velocity = stat["cat_#{cat.id}_velocity"] * 1
        stat["cat_#{cat.id}_percentage_velocity"] = @toPercent stat["cat_#{cat.id}_percentage_velocity"] * 1
        percent_velocity = stat["cat_#{cat.id}_percentage_velocity"] * 1


        totalCount += count
        counts.series[i+1].data.push count
        counts.seriesPercent[i].data.push  percent_count

        totalVelocity += velocity
        velocities.series[i+1].data.push velocity
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

  metricsForBoard: (boardId, siteId, callback)=>
    @$http.get("/api/boards/#{boardId}/stats.json?site_id=#{siteId}").success (res)=>
      data = @processData(res.data, res.board.categories)
      stats = _.sortBy(data.stats, (s) ->
        -1 * s.id)
      callback(stats, res.board, data)

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

angular.module('agilytics').factory('boardDataService', ["$http", ($http)->
  new BoardService($http)
])