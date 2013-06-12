class @AgileCubeService

  getCube: (callback)->
    if(@cube)
      callback @cube
    else
      @$http.get('/import/boards').success( (boards)=> @buildCube(boards, callback) ).error( -> alert('fail'))

  buildCube: (boards, callback)=>

    @cubifyAndRelateEntitites(boards)
    window.cube = @cube
    callback(@cube)


  add: colUtils.add

  push: colUtils.push

  cubifyAndRelateEntitites: (boards)->
    @cube = {}
    @cube.boards = boards
    @cube.boardsWithSprints = []
    @cube.assignees = []
    @cube.sprints = []

    for board in boards
      board.stories = [] unless board.stories
      board.assignees = [] unless board.assignees
      board.sprints = [] unless board.sprints

      if board.sprints.length
        @cubifyAndRelateBoard board
        @cube.boardsWithSprints.push board
        @aggregate_AssigneesStoriesSprints(board, @cube)
      else
        board.sprints = []

    @cube

  cubifyAndRelateBoard: (board)->
    _.each( board.sprints, (sprint) => @cubifyAndRelateSprints board, sprint )

  cubifyAndRelateSprints: (board, sprint)->
    sprint.initCommitment = 0
    sprint.totalCommitment = 0
    sprint.initVelocity = 0
    sprint.totalVelocity = 0
    sprint.estimateChangedVelocity = 0
    sprint.addedVelocity = 0
    sprint.assignees = [] unless sprint.assignees
    sprint.addedAssigneeNames = {}

    sprint.board = board

    for story in sprint.stories
      @ensureOnlyOneAssigneeIsCreatedPerHumanBeing(story)
      @doSprintCalculations board, sprint, story
      @cubifyStory board, sprint, story

    board.stories = _.union(sprint.stories, board.stories)

    board.assignees = _.union(sprint.assignees, board.assignees)


  ensureOnlyOneAssigneeIsCreatedPerHumanBeing: (story) ->
    if story.assignee
      story.assignee = @add(story.assignee)
                          .as(story.assignee.name)
                          .to("addedAssignees")
                          .on(@cube).ifAbsent()

  cubifyStory: (board, sprint, story) ->
    story.board = board
    story.sprint = sprint

  aggregate_AssigneesStoriesSprints: (src, dest)->

    initAndUnionAttrs = (attrs)->
      for attr in attrs
        dest[attr] = [] unless dest[attr]
        dest[attr] = _.union(dest[attr], src[attr])

    initAndUnionAttrs(["assignees", "sprints", "stories"])

  doSprintCalculations: (board, sprint, story)->
      @addUserFromStoryAndCalculateVelocity board, sprint, story
      @calculateCommitment sprint, story
      @calculateVelocity sprint, story

  calculateCommitment: (sprint, story)->
     sprint.initCommitment += (story.init_size || 0) unless story.was_added
     sprint.totalCommitment += (story.size || 0)

  calculateVelocity: (sprint, story) ->
     if story.done
        sprint.initVelocity += (story.init_size || 0) unless story.was_added
        sprint.estimateChangedVelocity += story.size - story.init_size  if story.size > story.init_size
        sprint.addedVelocity += (story.init_size || 0) if story.was_added
        sprint.totalVelocity += (story.size || 0)

  addUserFromStoryAndCalculateVelocity: (board, sprint, story)->
    if story.assignee
      story.size = story.size || 0
      @addCubifiedAndCalculatedAssignee( sprint, story.assignee, story, board )

  addCubifiedAndCalculatedAssignee: (sprint, assignee, story, board) ->
      sprint.addedAssigneeNames = sprint.addedAssigneeNames || {}

      @push(assignee).into("assignees").on(sprint).unless(!!sprint.addedAssigneeNames[assignee.name])

      assignee.velocities = [] unless assignee.velocities

      @push(sprint).into("sprints").on(assignee).now
      @push(story).into("stories").on(assignee).now
      @push(board).into("boards").on(assignee).now

      if story.done
        id = sprint.jid + board.jid
        velocityObj =
          velocity:0
          sprint: sprint
          sprintStartDate: sprint.change_set.startTime

        velocityObj = @add(velocityObj).as(id).to("velocities").on(assignee).ifAbsent()
        velocityObj.velocity += story.size
        velocityObj.boardId = board.jid

  constructor: ($http)-> @$http = $http

module.factory('agileCubeService', ["$http", ($http)-> new AgileCubeService($http) ])


