class BoardTeamService
  constructor: (@$http, @agiliticsUtils)->

  getTeamStats: (boardId, siteId, callback)=>
    @$http.get("/api/boards/#{boardId}/team_stats.json?site_id=#{siteId}").success (res)=>
      callback res

angular.module('agilytics').factory('boardTeamService', ["$http", "agiliticsUtils", ($http, agiliticsUtils)->
  new BoardTeamService($http, agiliticsUtils)
])