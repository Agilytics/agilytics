class CubeTester
  constructor: (cube)->
    @cube = cube

  runTests: ->

    describe 'TestCube is intact and', =>
      it 'cube should be truty', =>
        expect(@cube).toBeTruthy()

      it 'boards values', =>
        expect(@cube.boards).toBeTruthy()
        expect(@cube.boards.length).toEqual(11)

      it 'boards with sprints', =>
        expect(@cube.boardsWithSprints).toBeTruthy()
        expect(@cube.boardsWithSprints.length).toEqual(5)

      it 'assignees ', =>
        expect(@cube.assignees).toBeTruthy()
        expect(@cube.assignees.length).toEqual(21)
        expect(@cube.assignees.length).toEqual(_.uniq(@cube.assignees, false, (a)-> a.name).length)

      it 'sprints ', =>
        expect(@cube.sprints).toBeTruthy()
        expect(@cube.sprints.length).toEqual(41)
        sprints = []

        for board in @cube.boards
          sprints = _.union(sprints, board.sprints)
          expect(_.union(board.sprints).length).toEqual(board.sprints.length)

        expect(@cube.sprints.length).toEqual(sprints.length)


      it 'stories ', =>
        expect(@cube.stories).toBeTruthy()
        expect(@cube.stories.length).toEqual(834)
        storiesFrom = { boards: [], sprints: [] }

        for board in @cube.boards
          storiesFrom.boards = _.union(storiesFrom.boards, board.stories)
          for sprint in board.sprints
            storiesFrom.sprints = _.union(storiesFrom.sprints, sprint.stories)

        expect(@cube.stories.length).toEqual(storiesFrom.boards.length)
        expect(@cube.stories.length).toEqual(storiesFrom.sprints.length)

http = get: ()->
        success: (fn) ->
          fn(testdata.multi_boards_no_sub_tasks)
          { error: (fn) -> }

ac = new AgileCubeService(http)
ac.getCube(
  (cube)->
    ct = new CubeTester(cube)
    ct.runTests()
)
