module.directive('sprintGrid', [ "$http", ($http) ->

  NUM_BOARDS_PER_ROW = 5

  fetchGrid = (scope)=>
#    $http.get('sprint/grid').success (data) ->
    $http.get('/assets/grid.json').success (data) ->
      scope.grid = []
      scope.grid.push board for board in data when board.sprints && board.sprints.length
      _.each(scope.grid, (board)->
        _.each(board.sprints, (sprint)-> sprint.isChecked = false)
      )

  toggle = (id)=>
    board = _.find(@scope.grid, (board)-> return board.id == id)
    checkBoard(board, !board.isChecked)

  all = => checkBoard(board, true) for board in @scope.grid

  none = => checkBoard(board, false) for board in @scope.grid

  submit = =>
    if(@scope.model)
      @scope.model.grid = @scope.grid

  checkBoard = (board, checked) ->
    board.isChecked = checked
    _.each(board.sprints, (sprint)->
      sprint.isChecked = board.isChecked
    )

  linker = (scope, element, attr) =>
    scope.numPerRow = NUM_BOARDS_PER_ROW
    scope.columnWidth = Math.floor( 12 / scope.numPerRow )
    scope.toggle = toggle
    scope.all = all
    scope.none = none
    scope.submit = submit

    @scope = scope
    fetchGrid(scope)
    this

  restrict: 'E',
  link: linker,
  templateUrl: "/assets/directives/sprintGrid.html"
])