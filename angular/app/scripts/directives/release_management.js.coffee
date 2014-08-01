angular.module('agilytics').directive('releaseManagement', [ "$http", ($http) ->

  buildManager = ($scope)=>
      $scope.data = { date: '12/31/2014' }
      $scope.datepickerOptions =
                  format: 'yyyy-mm-dd'
                  language: 'fr'
                  startDate: "2012-10-01"
                  endDate: "2012-10-31"
                  autoclose: true
                  weekStart: 0

      $scope.sprints = []
      $scope.release = {
        name: "R1",
        description: "desc R1",
        sprints: [
          {id:1, name: "Sprint 4", start_date: "11/2/14", end_date: "12/1/14"}
          {id:2, name: "Sprint 5", start_date: "11/2/14", end_date: "12/1/14"}
          {id:3, name: "Sprint 6", start_date: "11/2/14", end_date: "12/1/14"}
          {id:4, name: "Sprint 4", start_date: "11/2/14", end_date: "12/1/14"}
          {id:5, name: "Sprint 5", start_date: "11/2/14", end_date: "12/1/14"}
          {id:6, name: "Sprint 6", start_date: "11/2/14", end_date: "12/1/14"}
          {id:7, name: "Sprint 4", start_date: "11/2/14", end_date: "12/1/14"}
          {id:8, name: "Sprint 5", start_date: "11/2/14", end_date: "12/1/14"}
          {id:9, name: "Sprint 6", start_date: "11/2/14", end_date: "12/1/14"}
          {id:11, name: "Sprint 4", start_date: "11/2/14", end_date: "12/1/14"}
          {id:12, name: "Sprint 5", start_date: "11/2/14", end_date: "12/1/14"}
          {id:13, name: "Sprint 6", start_date: "11/2/14", end_date: "12/1/14"}
          {id:14, name: "Sprint 4", start_date: "11/2/14", end_date: "12/1/14"}
          {id:15, name: "Sprint 5", start_date: "11/2/14", end_date: "12/1/14"}
          {id:16, name: "Sprint 6", start_date: "11/2/14", end_date: "12/1/14"}
          {id:17, name: "Sprint 4", start_date: "11/2/14", end_date: "12/1/14"}
          {id:18, name: "Sprint 5", start_date: "11/2/14", end_date: "12/1/14"}
          {id:19, name: "Sprint 6", start_date: "11/2/14", end_date: "12/1/14"}
        ]
      }

      $scope.removeSprintFromRelease = (sprint) ->
        for s, i in $scope.release.sprints when s.id == sprint.id
          $scope.release.sprints.splice(i, 1)
          $scope.sprints.push sprint

      $scope.addSprintToRelease = (sprint) ->
        for s, i in $scope.sprints when s.id == sprint.id
          $scope.sprints.splice(i, 1)
          $scope.release.sprints.push sprint

      $scope.releases = []
      $scope.releases.push
        name: "R1"
        description: "R1 was great"
        release_date: "6/10/14"
        sprints: [
          {name: "Sprint 1"}
          {name: "Sprint 2"}
          {name: "Sprint 3"}
        ]

      $scope.releases.push
        name: "R2"
        description: "R2 was not so great"
        release_date: "6/15/14"
        sprints: [
          {name: "Sprint 4"}
          {name: "Sprint 5"}
          {name: "Sprint 6"}
        ]

      $scope.releases.push
        name: "R3"
        description: "R3 was great"
        release_date: "7/1/14"
        sprints: [
          {name: "Sprint 7"}
          {name: "Sprint 8"}
          {name: "Sprint 9"}
        ]

      $("#manageRelease").modal()
      $("#release-date").datepicker(
        autoclose: true,
        todayHighlight: true
      )

  linker = (scope, element, attr) =>

    scope.openReleaseManagement = -> buildManager(scope)

    this

  restrict: 'E',
  link: linker,
  templateUrl: "views/directives/release_management.html"
])