module.directive('chosenSprints', [ "$http", ($http) ->
  fetchSprints = (scope)=>
    selectedBoards = @scope.boardsModel.selectedBoards
    if selectedBoards && selectedBoards.length
      boardIds = _.pluck(selectedBoards, "id")
      $http.post('import/sprints', { boardIds: boardIds }).success (data) =>
        alert JSON.stringify data
        # scope.sprintList = data.views

  all =  ()=> scope[@modelName] = @scope.sprintList
  none = ()=> scope[@modelName] = []

  linker = (scope, element, attr) ->
    @scope = scope
    @modelName = attr.ngModel

    triggerChosen = -> element.trigger('liszt:updated')

    scope.$watch("boardsModel.selectedBoards", fetchSprints)
    scope.$watch("sprintList", => triggerChosen)

    scope.allSprints = all
    scope.noSprints = none

    triggerChosen()
    this

  restrict: 'E',
  link: linker,
  templateUrl: "/assets/directives/chosenSprints.html"
])
