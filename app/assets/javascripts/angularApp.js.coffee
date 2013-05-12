window.module = angular.module('agilytics',['ui.compat'])
  .config(
    [
      '$stateProvider', '$routeProvider', '$urlRouterProvider',
      ($stateProvider, $routeProvider, $urlRouterProvider) ->

        $urlRouterProvider.when('/', '/boards').otherwise("/boards")

        $stateProvider.state(
          'boards', {
            url: '/boards',
            templateUrl: '/assets/metrics.html'
            controller: MetricsController
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
