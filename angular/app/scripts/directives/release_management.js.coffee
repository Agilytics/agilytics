angular.module('agilytics').directive('releaseManagement', [ "$http", "$rootScope", "$timeout", "agiliticsUtils", ($http, $rootScope,$timeout, agiliticsUtils) ->

  getReleases = ->

    @scope.releases.length = 0

    $http.get("/api/releases.json?board_id=#{@scope.board.id}&site_id=#{$rootScope.siteId}").success((releases)->
      for release in releases
        calculateReleaseCostAndVelocity(release)
        if release.release_date
          date = new Date(release.release_date)
          release.release_date = (date.getMonth() + 1) + '/' + date.getDate() + '/' +  date.getFullYear()
        release.release_date

        @scope.releases.push release
    )

  calculateReleaseCostAndVelocity = (release)->
    release.cost = 0
    release.total_velocity = 0
    for sprint in release.sprints
      calculateCost sprint
      release.cost += sprint.cost
      release.total_velocity += 1 * sprint.total_velocity
      console.log "#{release.name} #{sprint.name} sp:velocity #{1 * sprint.total_velocity}  calc:veloc #{ 1 * sprint.total_velocity}"

  calculateCosts = =>
    calculateReleaseCostAndVelocity(@scope.release)

    @scope.unreleased_sprint_costs = 0
    for sprint in @scope.sprints
      calculateCost sprint
      @scope.unreleased_sprint_costs += sprint.cost

  buildManager = =>

    $scope = @scope

    $scope.sprints = []

    $scope.releases = []

    getReleases()

    $scope.removeSprintFromRelease = (sprint) ->
      agiliticsUtils.moveAndSort($scope.release.sprints, $scope.sprints, sprint)
      calculateCosts()

    $scope.addSprintToRelease = (sprint) ->
      agiliticsUtils.moveAndSort($scope.sprints, $scope.release.sprints, sprint)
      calculateCosts()

    $("#manageRelease").modal()
    $("#release-date").datepicker(
      autoclose: true,
      todayHighlight: true,
      format:"mm/dd/yyyy"
    )
    null

  setRelease = (release) =>

    @scope.release = release

    @scope.canSave = => !!@scope.release && !!@scope.release.release_date && !!@scope.release.name

    null

  deleteRelease = () =>

    data = { release: @scope.release }
    $http(
      url: "/api/releases/delete.json?siteId=#{$rootScope.siteId}"
      method: "POST"
      data: JSON.stringify(data)
      headers: {'Content-Type': 'application/json'}
    ).success((data, status, headers, config) ->
      delete @scope.release
      @scope.sprints.length = 0
      getReleases()
    ).error((data, status, headers, config) ->
      alert 'error'
    )

  editRelease = (release)=>
    scope = @scope

    scope.sprints.length = 0
    getSprintsForBoard()

    scope.mode = {
      title : "Edit",
      action : "update"
    }

    setRelease(release)
    release.sprints = _.sortBy(release.sprints, (s)-> s.id )

    $timeout(
      -> $("#release-date").datepicker("update",new Date(scope.release.release_date))
    , 0)
    null

  saveRelease = =>
    return false if @scope.saveIsEnabled
    $scope = @scope

    data = { release: $scope.release }
    $http(
      url: "/api/releases/#{$scope.mode.action}.json?siteId=#{$rootScope.siteId}&boardId=#{$scope.board.id}"
      method: "POST"
      data: JSON.stringify(data)
      headers: {'Content-Type': 'application/json'}
    ).success((data, status, headers, config) ->
      delete $scope.release
      getReleases()
    ).error((data, status, headers, config) ->
      alert 'error'
    )

  calculateCost = (sprint)=>
    unless(sprint.cost)
      sprint.cost = @scope.board.run_rate_cost

  getSprintsForBoard = ->
    $scope = @scope
    $scope.sprints.length = 0

    $http.get("/api/sprints/forBoardNotReleased.json?board_id=#{$scope.board.id}&site_id=#{$rootScope.siteId}").success((sprints)->
      for sprint in sprints
        $scope.sprints.push sprint
        calculateCosts()
    )

  newRelease = =>
    scope = @scope
    scope.mode = {
      title : "New",
      action : "create"
    }
    getSprintsForBoard()

    setRelease {
      name: "",
      description: "",
      release_date: "",
      cost: 0,
      sprints: []
    }

    null

  linker = (scope, element, attr) =>
    @scope = scope
    scope.release = null

    scope.openReleaseManagement = buildManager
    scope.saveRelease = saveRelease
    scope.cancelRelease = ->
      scope.release = null
      getReleases()


    scope.newRelease = newRelease
    scope.editRelease = editRelease
    scope.deleteRelease = deleteRelease

    #listen for the open : calling scope must set a scope.control = {} and then call scope.control.open()
    scope.control.open = buildManager

    this

  restrict: 'E',
  link: linker,
  templateUrl: "views/directives/release_management.html"
  scope:
    board: "="
    control: "="

])