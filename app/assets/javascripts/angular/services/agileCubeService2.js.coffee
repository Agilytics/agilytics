class @AgileCubeService

  getCube: (callback)->
    if(@cube)
      callback @cube
    else
      @$http.get('/assets/cube.json').success( (srcCube)=> @buildCube(srcCube, callback) ).error( -> alert('fail'))

  buildCube: (srcCube, callback)=>

    @cubifyAndRelateEntitites(srcCube)
    window.cube = @cube
    callback(@cube)

  add: colUtils.add

  push: colUtils.push

  cubifyAndRelateEntitites: (srcCube)->
    @srcCube = srcCube

    @cube = {}
    @cube.boards = []
    @cube.boardsWithSprints = []
    @cube.sprints = []
    @cube.stories = []
    @cube.sprintStories = []
    @cube.assignees = []
    @cube.reporters = []
    @cube.workActivities = []
    @cube.changes = []
    @cube.subtasks = []

    for boardId of @srcCube.boards
      srcBoard = srcCube.boards[boardId]
      @createBoard(srcBoard)

    @cube

  process: (obj, fn)->
    unless(obj.__processed)
      obj.__processed = true
      fn(obj)

    obj


  createBoard: (board)=>
    @process board, (board)=>

      @alter('board', board)
          .addSprints()
          .addStories()
          .addChanges()
          .addWorkActivities()

      @cube.boards.push(board)

  createSprint: (sprintId)=>
    @process @srcCube.sprints[sprintId], (sprint)=>

      @alter('sprint', sprint )
        .addStories()
        .addSprintStories()
        .addChanges()
        .addWorkActivities()
        .addAssignees()
        .addReporters()

      @cube.sprints.push(sprint)


  createStory: (storyId)=>
    @process @srcCube.stories[storyId], (story)=>

      @alter('story', story )
        .addSprintStories()

      @cube.stories.push(story)

  createAssignee: (assigneeId)=>
    @process @srcCube.assignees[assigneeId], (assignee)=>

      @alter('assignee', assignee )
        .addWorkActivities()
        .addSprintStories()
        .addStories()

      @cube.assignees.push(assignee)

  createReporter: (reporterId)=>
    @process @srcCube.reporters[reporterId], (reporter)=>

      @alter('reporter', reporter )
        .addSprintStories()
        .addStories()

      @cube.reporters.push(reporter)

  createChange: (changeId)=>
    @process @srcCube.changes[changeId], (change)=>
      @cube.changes.push(change)

  createWorkActivity: (workActivityId)=>
    @process @srcCube.workActivities[workActivityId], (workActivity)=>
      @cube.workActivities.push(workActivity)

  createSprintStory: (sprintStoryId)=>
    @process @srcCube.sprintStories[sprintStoryId], (sprintStory)=>
      @cube.sprintStories.push sprintStory

  createSubtask: (subtaskId)=>
    @process @srcCube.subtasks[subtaskId], (subtask)=>
      @cube.subtasks.push(subtask)

  constructor: ($http)-> @$http = $http

  withIds: (ids)->
    make: (collectionName)->
      using: (createFn)->
        andPutOn: (srcName, object)->
          object[collectionName] = [] unless object[collectionName]
          _.each(ids, (id)->
            createdObj = createFn(id)
            createdObj[srcName] = object
            object[collectionName].push(createdObj)
          )

  alter: (name, src)=>
    self = @
    ops =
      addSprints: -> self.withIds(src.sprintIds).make('sprints').using(self.createSprint).andPutOn(name, src); ops;
      addStories: -> self.withIds(src.storyIds).make('stories').using(self.createStory).andPutOn(name, src); ops;
      addSprintStories: -> self.withIds(src.sprintStoryIds).make('sprintStories').using(self.createSprintStory).andPutOn(name, src); ops;
      addChanges: -> self.withIds(src.changeIds).make('changes').using(self.createChange).andPutOn(name, src); ops;
      addAssignees: -> self.withIds(src.assigneeIds).make('assignees').using(self.createAssignee).andPutOn(name, src); ops;
      addReporters: -> self.withIds(src.reporterIds).make('reporters').using(self.createReporter).andPutOn(name, src); ops;
      addWorkActivities: -> self.withIds(src.workActivityIds).make('workActivities').using(self.createWorkActivity).andPutOn(name, src); ops;

    ops


module.factory('agileCubeService', ["$http", ($http)-> new AgileCubeService($http) ])


