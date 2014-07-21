phonecatApp = angular.module('phonecatApp', [
  'ngRoute',
  'phonecatControllers'
])

phonecatApp.config [
  "$routeProvider"
  ($routeProvider) ->
    debugger
    $routeProvider.when("/phones",
      controller: "PhoneListCtrl"
    ).otherwise(
      redirectTo: "/phones"
    )
]

phonecatControllers = angular.module("phonecatControllers", [])

phonecatControllers.controller "PhoneListCtrl", ->
    alert 'aye'

