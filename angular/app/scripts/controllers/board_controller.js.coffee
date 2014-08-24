angular.module("agilytics").controller "BoardController", ($scope, $http, $location,
                                                           $stateParams, $timeout, $rootScope,
                                                           boardDataService, agiliticsUtils)->
  $scope.board = {id: $stateParams.boardId}
  $scope.releaseManager = {} # for release manager
  $scope.canSaveBoard = =>
    $scope.board.name && $scope.board.run_rate_cost

  $scope.cancelEdit = =>
    $scope.edit = false

  #------------ TAGS / CATEGORY

  $scope.createCategory = ()->
    $scope.category = {
      name:""
      tags:[]
    }
  $scope.editCategory = (category)->
    $scope.category = category

  $scope.removeTagFromCategory = (tag,category)->
    agiliticsUtils.moveAndSort(category.tags, $scope.tags , tag)

  $scope.addTagToCategory = (tag,category)->
    agiliticsUtils.moveAndSort($scope.tags, category.tags, tag)

  $scope.canSaveCategory = (category)-> !! (category && category.name)

  $scope.saveCategory = (category)=>
    category.tags = [] unless category.tags
    boardDataService.saveCategories($stateParams.boardId, $rootScope.siteId, [category], =>
      boardDataService.getCategories $stateParams.boardId, $rootScope.siteId, (categories)=>
        $scope.board.categories = categories
        $scope.category = null
    )

  $scope.deleteCategory = (category)->
    boardDataService.deleteCategory $stateParams.boardId, $rootScope.siteId, category.id, ->
      boardDataService.getCategories $stateParams.boardId, $rootScope.siteId, (categories) ->
        $scope.board.categories = categories
        $scope.category = null

  $scope.cancelEditCategory = (category)->
    $scope.category = null
  #------------

  $scope.editBoard = =>
    $scope.edit = true
    $scope.categories = null
    boardDataService.getCategories $stateParams.boardId, $rootScope.siteId, (categories)=>
      $scope.board.categories = categories


  $scope.saveBoard = ->
    data = { board: $scope.board }
    boardDataService.save scope.board.id, $rootScope.siteId, data, (data)->
      $scope.edit = false
      $scope.board = data
      window.location.reload()

  showGraph = (id, title, categories, series, xAxis, enableLegend, isPercent)->
    #http://jsfiddle.net/gh/get/jquery/1.9.1/highslide-software/highcharts.com/tree/master/samples/highcharts/demo/area-stacked/
    options =
      chart:
        type: "column"

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
        column:
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

  boardDataService.metricsForBoard($stateParams.boardId, $rootScope.siteId, (stats, board, data)->
    $scope.stats = stats
    $scope.board = board
    $scope.tags = []

    boardDataService.getTags $stateParams.boardId, $rootScope.siteId, (tags)->
      $scope.tags = tags

    sg = ->
      sprints = data.sprints

      showGraph("velocity", "By Velocity", sprints, data.velocities.series, "Story Points", true)
      showGraph("velocityPercent", "By % Velocity", sprints, data.velocities.seriesPercent, "Percent Story Points",
        false, true)
      showGraph("counts", "By Count", sprints, data.counts.series, "Number")
      showGraph("countsPercent", "By % Count", sprints, data.counts.seriesPercent, "Percent of Count", false, true)

    $scope.editBoard()
    $timeout(sg, 0)
  )

  this