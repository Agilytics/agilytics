class @BoardsSelectorController
  constructor: ($scope, $http)->
    @scope = $scope
    @scope.boardsModel = {
      selectedBoards: []
    }
    @scope.$watch "model.grid", => @getGrid() if @scope.model.grid
    @http = $http

  getGrid: ->
    grid = @scope.model.grid
    passGrid = []
    _.each(grid, (board)->
      lboard =
          add:false
          sprints: []
      _.each(board.sprints, (sprint)->
        if sprint.isChecked
          lboard.add = true
          lboard.id = board.id
          lboard.sprints.push sprint
      )
      passGrid.push lboard if lboard.add
    )

    @http.post('import/gridChanges', passGrid).success (data) ->
      alert JSON.stringify data, null, 2
    .error -> alert 'fail'

#BoardsSelectorController.$inject = ['$scope', '$http'];
