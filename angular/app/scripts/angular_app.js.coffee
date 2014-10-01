angular.module('agilytics', ['ui.compat'])
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
          url: '/boards',
          templateUrl: 'views/boards.html'
          controller: "BoardsController"
        }
      )
      .state(
        'board', {
          url: '/boards/{boardId}?from&to',
          controller:"BoardController"
          templateUrl: 'views/board.html',
          dpts: ($state, $stateParams) ->
            boardId: $stateParams.boardId
            from: $stateParams.from
            to: $stateParams.to

        }
      )
      .state(
        'board.stats', {
          url: '/stats',
          templateUrl: 'views/board_stats.html',
          controller: "BoardStatsController"
        }
      ).state(
        'board.teamMembers',
        {
          url: '/team',
          templateUrl: 'views/board_team.html',
          controller: "TeamBoardController"
        }
      )

      #.state(
      #  'board', {
      #    url: '/boards/:boardId/:from/:to',
      #    templateUrl: 'views/board.html',
      #    controller: "BoardController"
      #  }
      #)
      #.state(
      #  'board.dates.teamMembers', {
      #    url: '/boards/:boardId.teamMembers/:from/:to',
      #    templateUrl: 'views/board.html',
      #    controller: "BoardController"
      #}


  ]).run([ '$rootScope', '$state', '$stateParams',
    ($rootScope, $state, $stateParams) ->
      getUrlParameter = (sParam) ->
        sPageURL = window.location.search.substring(1)
        sURLVariables = sPageURL.split("&")
        i = 0

        while i < sURLVariables.length
          sParameterName = sURLVariables[i].split("=")
          return sParameterName[1]  if sParameterName[0] is sParam
          i++

      $rootScope.$state = $state
      $rootScope.$stateParams = $stateParams
      $rootScope.siteId = getUrlParameter('site')
      if getUrlParameter('site')
        $("#boards").toggleClass("hide")

  ]
)
