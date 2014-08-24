class @CategoryService
  constructor: (@$http)->

  saveCategories: (boardId, siteId, categories, callback)=>
    data = {
      categories: categories,
    }

    @$http(
      url: "/api/boards/#{boardId}/setCategories.json?siteId=#{siteId}"
      method: "POST"
      data: JSON.stringify(data)
      headers: {'Content-Type': 'application/json'}
    ).success((data, status, headers, config) ->
      callback(data)
    ).error((data, status, headers, config) ->
      alert 'error'
    )

angular.module('agilytics').factory('categoryDataService', ["$http", ($http)->
  new CategoryService($http)
])