angular.module('agilytics',['ui.compat'])
  .config(
    [
      '$stateProvider', '$routeProvider', '$urlRouterProvider',
      ($stateProvider, $routeProvider, $urlRouterProvider) ->

        $urlRouterProvider.when('/', '/boards').otherwise("/boards")

        $stateProvider.state(
          'boards', {
            url: '/boards',
            templateUrl: 'views/boards.html'
            controller: "BoardsController"
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
    ]
  ).run([ '$rootScope', '$state', '$stateParams',
        ($rootScope, $state, $stateParams) ->
          $rootScope.$state = $state
          $rootScope.$stateParams = $stateParams
        ]
)
