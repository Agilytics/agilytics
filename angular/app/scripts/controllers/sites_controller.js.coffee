angular.module("agilytics").controller "SitesController", ($scope, $http) ->

  $http.get("/api/sites.json").success (data)->
    $scope.sites = data

  $scope.href = (site)-> window.location = "?site=#{site.id}#/boards"

  this

