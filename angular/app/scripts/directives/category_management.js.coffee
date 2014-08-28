angular.module('agilytics').directive('categoryManagement', [ "$http", "$rootScope", "$timeout", "agiliticsUtils", "boardDataService"

  ($http, $rootScope,$timeout, agiliticsUtils, boardDataService) ->

    #------------ TAGS / CATEGORY
    buildManager = =>

      @scope.createCategory = =>
        @scope.category = {
          name:""
          tags:[]
        }

      @scope.editCategory = (category)=>
        @scope.category = category

      @scope.removeTagFromCategory = (tag,category)=>
        agiliticsUtils.moveAndSort(category.tags, @scope.tags , tag)

      @scope.addTagToCategory = (tag,category)=>
        agiliticsUtils.moveAndSort(@scope.tags, category.tags, tag)

      @scope.canSaveCategory = (category)=> !! (category && category.name)

      @scope.saveCategory = (category)=>
        category.tags = [] unless category.tags
        boardDataService.saveCategories(@board.id, $rootScope.siteId, [category], =>
          boardDataService.getCategories @board.id, $rootScope.siteId, (categories)=>
            @scope.board.categories = categories
            @scope.category = null
        )

      @scope.deleteCategory = (category)=>
        boardDataService.deleteCategory @board.id, $rootScope.siteId, category.id, ->
          boardDataService.getCategories @board.id, $rootScope.siteId, (categories) ->
            @scope.board.categories = categories
            @scope.category = null

      @scope.cancelEditCategory = (category)=>
        @scope.category = null

      boardDataService.getCategories @board.id, $rootScope.siteId, (categories)=>
        boardDataService.getTags @board.id, $rootScope.siteId, (tags)->
          @scope.tags = tags
          @scope.board.categories = categories
          $("#manageCategories  ").modal()

      null
    #------------

    linker = (scope, element, attr) =>
      @scope = scope
      #listen for the open : calling scope must set a scope.control = {} and then call scope.control.open()
      scope.control.open = buildManager
      this

    restrict: 'E',
    link: linker,
    templateUrl: "views/directives/category_management.html"
    scope:
      board: "="
      control: "="

])