class @MetricsController
  getBoards: ()=>
    $.getJSON('/sprint/boards' ).success( @processBoards ).fail( -> alert('fail'))

  processBoards: (boards)=>
    @scope.boards = (board for board in boards when board.sprints)

  constructor: ($scope, $http)->
    @http = $http
    @scope = $scope
    @scope.model = {}
    @http = $http
    @getBoards()
    this

#MetricsController.$inject = ['$scope', '$http']