module.directive('chosenBoards', [ "$http", ($http) ->
  fetchBoards = (scope)=>
    $http.get('import/boards').success (data) ->
      scope.boardList = data.views

  all =  (scope)-> scope.boards = scope.boardList

  none = (scope)-> scope.boards = []

  linker = (scope, element, attr) =>

    $select = $("select", element);

    triggerChosen = -> $select.trigger('liszt:updated')

    scope.$watch('boardList', triggerChosen)
    scope.$watch('boards', triggerChosen)

    scope.allBoards = -> all(scope)
    scope.noBoards = -> none(scope)

    scope.selectedBoards = ->
      scope.boardsModel.selectedBoards = scope.boards

    $select.chosen()
    fetchBoards(scope)
    this

  restrict: 'E',
  link: linker,
  templateUrl: "/assets/directives/chosenBoards.html"
])