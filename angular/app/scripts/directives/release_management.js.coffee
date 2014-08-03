angular.module('agilytics').directive('releaseManagement', [ "$http", "$rootScope", "$timeout", ($http, $rootScope,$timeout) ->

  getReleases = ->
    $http.get("/api/releases.json?board_id=#{@scope.board.id}&site_id=#{$rootScope.siteId}").success((releases)->
      for release in releases
        if release.release_date
          date = new Date(release.release_date)
          release.release_date = (date.getMonth() + 1) + '/' + date.getDate() + '/' +  date.getFullYear()
        release.release_date
        @scope.releases.push release
    )

  buildManager = =>

    $scope = @scope

    $scope.sprints = []

    $scope.releases = []

    getReleases()

    moveAndSort = (fromCollection, toCollection, sprint)->
      for s, i in fromCollection
        if s.id == sprint.id
          fromCollection.splice(i, 1)
          toCollection.push sprint
          sprints = _.sortBy(toCollection, (s)->s.id)
          toCollection.length = 0
          for sprint in sprints
            toCollection.push sprint
          break

    $scope.removeSprintFromRelease = (sprint) ->
      moveAndSort($scope.release.sprints, $scope.sprints, sprint)

    $scope.addSprintToRelease = (sprint) ->
      moveAndSort($scope.sprints, $scope.release.sprints, sprint)

    $("#manageRelease").modal()
    $("#release-date").datepicker(
      autoclose: true,
      todayHighlight: true
    )
    null

  editRelease = (release)->
    scope = @scope

    scope.sprints.length = 0
    getSprintsForBoard()
    scope.mode = {
      title : "Edit",
      action : "update"
    }
    scope.release = release
    $timeout(
      -> $("#release-date").datepicker("update",new Date(scope.release.release_date))
    , 0)
    null

  saveRelease = =>
    $scope = @scope
    data = { release: $scope.release }
    $http(
      url: "/api/releases/#{$scope.mode.action}.json?siteId=#{$rootScope.siteId}&boardId=#{$scope.board.id}"
      method: "POST"
      data: JSON.stringify(data)
      headers: {'Content-Type': 'application/json'}
    ).success((data, status, headers, config) ->
      delete $scope.release
    ).error((data, status, headers, config) ->
      alert 'error'
    )

  cancelRelease = ->
    scope = @scope
    scope.release = null

  getSprintsForBoard = ->
    $scope = @scope

    $http.get("/api/sprints/forBoard.json?board_id=#{$scope.board.id}&site_id=#{$rootScope.siteId}").success((sprints)->
      for sprint in sprints
        $scope.sprints.push sprint
    )

  newRelease = =>
    scope = @scope
    scope.mode = {
      title : "New",
      action : "create"
    }
    getSprintsForBoard()

    scope.release = {
      name: "",
      description: "",
      release_date: "",
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


    scope.newRelease = newRelease
    scope.editRelease = (release)-> editRelease(release)

    #listen for the open : calling scope must set a scope.control = {} and then call scope.control.open()
    scope.control.open = buildManager

    buildManager()

    this

  restrict: 'E',
  link: linker,
  templateUrl: "views/directives/release_management.html"
  scope:
    board: "="
    control: "="

])