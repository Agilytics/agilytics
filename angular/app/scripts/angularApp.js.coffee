angular.module('agilytics',['ui.compat'])
  .config(
    [
      '$stateProvider', '$routeProvider', '$urlRouterProvider',
      ($stateProvider, $routeProvider, $urlRouterProvider) ->

        $urlRouterProvider.when('/', '/all').otherwise("/all")

        $stateProvider.state(
          'all', {
            url: '/all',
            templateUrl: 'views/metrics.html'
            controller: MetricsController
          }
        )
        .state(
          'sprints', {
            url: '/sprints/:sprintId?all',
            templateUrl: 'views/sprint.html'
            controller: SprintController
            onExit: -> $("body").off("keydown");
          }
        )
        .state(
          'boards', {
            url: '/boards',
            templateUrl: 'views/boards.html'
            controller: BoardsController
          }
        )
    ]
  ).run([ '$rootScope', '$state', '$stateParams',
        ($rootScope, $state, $stateParams) ->
          $rootScope.$state = $state
          $rootScope.$stateParams = $stateParams
        ]
)
