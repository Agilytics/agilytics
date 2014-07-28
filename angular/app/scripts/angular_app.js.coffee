angular.module('agilytics',['ui.compat'])
  .config(
    [
      '$stateProvider', '$routeProvider', '$urlRouterProvider',
      ($stateProvider, $routeProvider, $urlRouterProvider) ->

        $urlRouterProvider.when('/', '/sites').otherwise("/sites")

        $stateProvider.state(
          'sites', {
            url: '/sites',
            templateUrl: 'views/sites.html'
            controller: "SitesController"
          }
        )
        .state(
          'boards', {
            url: '/sites/:siteId/boards',
            templateUrl: 'views/boards.html'
            controller: "BoardsController"
          }
        )
        .state(
          'board', {
            url: '/sites/:siteId/boards/:boardId',
            templateUrl: 'views/board.html',
            controller: "BoardController"
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
