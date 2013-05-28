window.module = angular.module('agilytics',['ui.compat'])
  .config(
    [
      '$stateProvider', '$routeProvider', '$urlRouterProvider',
      ($stateProvider, $routeProvider, $urlRouterProvider) ->

        $urlRouterProvider.when('/', '/all').otherwise("/all")

        $stateProvider.state(
          'all', {
            url: '/all',
            templateUrl: '/assets/metrics.html'
            controller: MetricsController
          }
        )
        .state(
          'boards', {
            url: '/boards',
            templateUrl: '/assets/boards.html'
            controller: BoardsController
          }
        )
        .state(
          'refreshData', {
            url: '/refreshData',
            templateUrl: '/assets/refreshSprintData.html',
            controller: RefreshSprintData
          }
        )
    ]
  ).run([ '$rootScope', '$state', '$stateParams',
        ($rootScope, $state, $stateParams) ->
          $rootScope.$state = $state
          $rootScope.$stateParams = $stateParams
        ]
)
