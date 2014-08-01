
angular.module("agilytics").controller "BoardController", ($scope, $http, $location, $stateParams, $timeout, $rootScope )->

    toPercent = (i)-> Math.round(i * 100)

    showGraph = (id, title, categories, series, xAxis, enableLegend, isPercent)->
      #http://jsfiddle.net/gh/get/jquery/1.9.1/highslide-software/highcharts.com/tree/master/samples/highcharts/demo/area-stacked/
      options =
        chart:
          type: "area"

        title:
          text: title

        xAxis:
          categories: categories
          labels:
            rotation: 45
            step: 2

          tickmarkPlacement: "on"

        yAxis:
          title:
            text: xAxis

        legend:
          enabled: enableLegend
          align: 'center',
          verticalAlign: 'top',
          floating: true,
          x: 0,
          y: 30

        tooltip:
          shared: true

        plotOptions:
          area:
            stacking: "normal"
            lineColor: "#666666"
            lineWidth: 1
            marker:
              enabled: false
              lineWidth: 1
              radius: 2
              lineColor: "#666666"

        series: series

      if isPercent
        options.yAxis.min = 0
        options.yAxis.max = 100

      $("\##{id}").highcharts options

    processData = (data)->
      # colors: http://coolmaxhot.com/graphics/hex-color-palette.htm
      buildSeries = (withTotal)->
        ret = []
        ret.push { name:"total", data:[], color: '#666', lineWidth: 0.5, marker: { radius:2, lineColor:"#DFDFDF" }, type: 'line'} if withTotal
        ret.push { name:"bugs", data:[], color: '#FFDDDD'}
        ret.push { name:"enhancements", data:[], color:'#94BAE7' }
        ret.push { name:"features", data:[], color: '#31659C' }
        ret

      sprints = []

      counts = {}
      counts.series = buildSeries(true)
      counts.seriesPercent = buildSeries()

      velocities = {}
      velocities.series = buildSeries(true)
      velocities.seriesPercent = buildSeries()

      for stat in data

        sprints.push stat.sprint_name.replace('Sprint','  ')

        counts.series[0].data.push stat.total_count * 1
        counts.series[1].data.push stat.bug_count * 1
        counts.series[2].data.push stat.enhancement_count * 1
        counts.series[3].data.push stat.feature_count * 1

        #
        stat.feature_percentage_count = toPercent(stat.feature_percentage_count)
        stat.enhancements_percentage_count = toPercent(stat.enhancements_percentage_count)
        stat.bug_percentage_count = toPercent(stat.bug_percentage_count)
        #

        counts.seriesPercent[0].data.push stat.bug_percentage_count
        counts.seriesPercent[1].data.push stat.enhancements_percentage_count
        counts.seriesPercent[2].data.push stat.feature_percentage_count

        velocities.series[0].data.push stat.total_velocity  * 1
        velocities.series[1].data.push stat.bug_velocity  * 1
        velocities.series[2].data.push stat.enhancement_velocity  * 1
        velocities.series[3].data.push stat.feature_velocity  * 1

        #
        stat.feature_percentage_velocity = toPercent(stat.feature_percentage_velocity)
        stat.enhancements_percentage_velocity = toPercent(stat.enhancements_percentage_velocity)
        stat.bug_percentage_velocity = toPercent(stat.bug_percentage_velocity)
        velocities.seriesPercent[0].data.push stat.bug_percentage_velocity
        velocities.seriesPercent[1].data.push stat.enhancements_percentage_velocity
        velocities.seriesPercent[2].data.push stat.feature_percentage_velocity

      sprints: sprints
      stats: data
      counts: counts
      velocities: velocities


    $http.get("/api/boards/#{$stateParams.boardId}/stats.json?site_id=#{$rootScope.siteId}").success((res)->
      data = processData(res.data)
      $scope.stats = data.stats
      $scope.board = res.board
      sg = ->
        sprints = data.sprints
        showGraph("velocity", "By Velocity", sprints, data.velocities.series, "Story Points", true)
        showGraph("velocityPercent", "By % Velocity", sprints, data.velocities.seriesPercent, "Percent Story Points", false, true)
        showGraph("counts", "By Count", sprints, data.counts.series, "Number")
        showGraph("countsPercent", "By % Count", sprints, data.counts.seriesPercent, "Percent of Count", false, true)
      $timeout(sg, 0)
    )

    this

