module.directive('boardSummary', [ "$http", ($http) ->

  init = =>
    @scope.sprintRows = []
    @scope.headers = [
        "Sprint Name",
        "Start Date",
        "Initial Commitment",
        "Total Commitment",
        "Initial Velocity",
        "Total Velocity"
      ]

  processSprint = (sprint)=>
    initCommitment = 0
    totalCommitment = 0
    initVelocity = 0
    totalVelocity = 0

    if sprint.stories
      for curStory in sprint.stories
        initCommitment += (curStory.init_size || 0) unless curStory.was_added
        totalCommitment += (curStory.size || 0)
        if curStory.done
          initVelocity += (curStory.init_size || 0) unless curStory.was_added
          totalVelocity += (curStory.size || 0)

    startDate = new Date(sprint.changeset.startTime)
    month = startDate.getMonth() + 1
    year =  startDate.getFullYear()
    date =  startDate.getDate()
    cols = []
    cols.push "#{sprint.name}"
    cols.push "#{month}/#{date}/#{year}"
    cols.push "#{initCommitment}"
    cols.push "#{totalCommitment}"
    cols.push "#{initVelocity}"
    cols.push "#{totalVelocity}"

    @scope.sprintRows.push(cols)
    console.log( JSON.stringify(cols, null, 2))

  linker = (scope, element, attr) =>
    sprints = scope.board.sprints

    @scope = scope
    init()
    if(sprints)
      processSprint sprint for sprint in sprints

    this

  restrict: 'E',
  link: linker,
  templateUrl: "/assets/directives/boardSummary.html"
])
