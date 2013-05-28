module.factory('gridService', ->

  class GridService
    getBoards: (callback)=>
      $.getJSON('/sprint/boards' ).success( (boards)=> @processBoards(boards, callback) ).fail( -> alert('fail'))

    processBoards: (boards, callback)=>

      global = {}

      for board in boards when board.sprints
        _.each( board.sprints, (s) => @processSprints global, board, s )

      boards = (board for board in boards when board.sprints)
      assignees = global.assignees

      callback(boards, assignees)

    processSprints: (global, board, sprint)=>
      sprint.initCommitment = 0
      sprint.totalCommitment = 0
      sprint.initVelocity = 0
      sprint.totalVelocity = 0
      sprint.estimateChangedVelocity = 0
      sprint.addedVelocity = 0

      sprint.assignees = {} unless sprint.assignees

      if sprint.stories
        for story in sprint.stories
          @addUserFromStoryAndCalculateVelocity global, board, sprint, story
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

    addUserFromStoryAndCalculateVelocity: (global, board, sprint, story)->
      addAssignee = (o, assignee)->
        o.assignees = o.assignees || {}
        o.assignees[assignee.name] = assignee unless o.assignees[assignee.name]
        o.assignees[assignee.name].velocities = [] unless o.assignees[assignee.name].velocities

      addVelocity = (o, assignee, story)->
        if story.done
          id = sprint.jid + board.jid
          assigneeVelocities = o.assignees[assignee.name].velocities
          assigneeVelocities[id] = {velocity:0, sprintStartDate: sprint.change_set.startTime} unless assigneeVelocities[id]
          assigneeVelocities[id].velocity += story.size
          assigneeVelocities[id].boardId = board.jid


      addAssigneeAndVelocity = (objs, assignee, story) ->
        for o in objs
          addAssignee(o, assignee)
          addVelocity(o, assignee, story)

      if story.assignee
        story.size = story.size || 0
        objs = [global, board, sprint]
        addAssigneeAndVelocity( objs, story.assignee, story )

    constructor: ->

  new GridService()

)