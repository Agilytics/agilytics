angular.module('agilytics').directive('sprintSummary', [ "$http", "$timeout", "agiliticsUtils", ($http, $timeout, agiliticsUtils) -> new SprintSummary($http, $timeout, agiliticsUtils)])

class SprintSummary

  constructor: ($http, $timeout, agiliticsUtils) ->
    @$timeout = $timeout
    @agiliticsUtils = agiliticsUtils

  attachKeyDown: (sprint, sprints)=>
    thisSprintFound = false
    left = null
    right = null

    _.each sprints, (lSprint)->
        if sprint == lSprint
          thisSprintFound = true
        else if thisSprintFound && !right
          right = lSprint
          console.log(right)

        if !thisSprintFound
          left = lSprint

    $("body").keydown (e)=>
        if((e.keyCode || e.which) == 37)
          @gotoSprint(left) if left
        if((e.keyCode || e.which) == 39)
          @gotoSprint(right) if right

  createDataPoint = (date, change, velocity, action)->
    x: date
    y: velocity
    change: change
    action: action

  gotoSprint: (sprint)=>
    window.location.hash = "/sprints/#{sprint.pid}"

  link: (scope, element, attr) =>

    scope.colors = {} unless scope.colors
    scope.gotoSprint = @gotoSprint
    scope.dateFormat = @agiliticsUtils.dateFormat
    scope.showAllSprints = false

    scope.$watch "sprint", => @renderSummary(scope) if(scope.sprint)

    this

  renderSummary: (scope)=>
      sprint = scope.sprint
      scope.sprints = scope.sprint.board.sprints
      scope.selectedSprint = sprint

      @attachKeyDown(sprint, scope.sprints)

      added = { title: "Added Velocity : Stories that were added & finished.", color: scope.colors.addedVelocity || "purple", sprintStories:[], size: 0 }
      changed = { title: "Changed Velocity : Stories that were changed & finished.", color: scope.colors.changedVelocity || "purple", sprintStories:[], size: 0 }
      removedCommitted = { title: "Removed-Commited: Stories committed and removed.", color: scope.colors.removedCommitted || "purple", sprintStories:[], size: 0 }
      removedAdded = { title: "Removed-Added: Stories added and removed.", color: scope.colors.removedAdded || "purple", sprintStories:[], size: 0 }
      missedAdded = { title: "Missed-Added: Stories added and were missed.", color: scope.colors.missedAdded || "purple", sprintStories:[], size: 0 }
      missedCommitted = { title: "Missed-Committed: Stories committed to and missed." , color: scope.colors.missedCommitted || "purple", sprintStories:[], size: 0 }



      for sprintStory in sprint.sprintStories

        if sprintStory.wasAdded && sprintStory.isDone
          added.sprintStories.push sprintStory
          added.size += sprintStory.size

        if (sprintStory.initSize != sprintStory.size) && !sprintStory.wasAdded
          changed.sprintStories.push sprintStory
          changed.size += Math.abs(sprintStory.size - sprintStory.initSize)

        if sprintStory.wasRemoved && !sprintStory.wasAdded
          removedCommitted.sprintStories.push sprintStory
          removedCommitted.size += sprintStory.size

        if sprintStory.wasRemoved && sprintStory.wasAdded
          removedAdded.sprintStories.push sprintStory
          removedAdded.size += sprintStory.size

        if sprintStory.wasAdded && !sprintStory.isDone && !sprintStory.wasRemoved
          missedAdded.sprintStories.push sprintStory
          missedAdded.size += sprintStory.size

        if !sprintStory.wasAdded && !sprintStory.isDone && !sprintStory.wasRemoved
          missedCommitted.sprintStories.push sprintStory
          missedCommitted.size += sprintStory.size

      scope.usualSuspects = _.filter([missedCommitted, removedCommitted, changed, added, removedAdded, missedAdded], (s)-> s.size)

      scope.showGraph = =>
        primarySprint = @buildSprintPoints(sprint, scope.showAllSprints)
        changeDates = _.map(primarySprint.changeDates, (o)-> {date: o.dateStr, netValue: o.netValue, changes: o.changes, netVelocity: o.netVelocity} )
        scope.count = changeDates.length
        scope.changeDates = changeDates

        data = []
        for otherSprint in sprint.board.sprints when otherSprint != sprint && otherSprint.closed && scope.showAllSprints
          otherPoints = @buildSprintPoints(otherSprint, scope.showAllSprints)
          data.push { type: "line", name: "committed", step: 'left', color: "#DEDEDE", lineWidth:3, showInLegend: false, marker:{ enabled: false }, data: otherPoints.committedPoints}

        data.push { type: "line", name: "committed", step: 'left', color: scope.colors.committedVelocity || "purple", lineWidth: 4, marker:{ enabled: false }, data: primarySprint.committedPoints}
        data.push { type: "scatter", name: "added", step: 'left', color: scope.colors.addedVelocity || "purple", marker:{ symbol: "circle", enabled: true, radius: 6 }, data: primarySprint.addedPoints}
        data.push { type: "scatter", name: "changed", step: 'left', color: scope.colors.changedVelocity || "purple",  marker:{ symbol: "triangle", enabled: true, radius: 8 }, data: primarySprint.changePoints}
        data.push { type: "scatter", name: "removed", step: 'left', color: scope.colors.removedCommitted || "purple",  marker:{ symbol: "diamond", enabled: true, radius: 8 }, data: primarySprint.removedPoints}

        sg = => @showGraph sprint, data, !scope.showAllSprints

        @$timeout(sg, 0) if sg

      scope.showGraph()


  buildSprintPoints: (sprint, useRelativeDates)=>
    committedPoints = []
    removedPoints = []
    changePoints = []
    addedPoints = []
    changeDates = {}
    velocity = 0

    sprint.changes = _.sortBy(sprint.changes, (c)-> new Date(c.time))
    sprintStartDate = new Date(sprint.startDate)

    buildXAxis = (date)=>
      if useRelativeDates
        @agiliticsUtils.differenceInDays(sprintStartDate, date)
      else
        date

    for change in sprint.changes

      for pc in @changeProcessors when change.action.indexOf(pc.action) >= 0

        changeTime = new Date(change.time)

        # don't consider changes that came before the sprint start
        continue unless changeTime >= sprintStartDate

        ch = pc.process(change)
        dayOfChanges = @initOrGetDayOfChanges(changeTime, changeDates, day1, ch.type)
        dayOfChanges.changes.push ch

        velocity += ch.value
        ch.netVelocity = velocity
        dayOfChanges.netValue += ch.value
        dayOfChanges.netVelocity = velocity

        day1 = dayOfChanges unless day1

        # if changes on a different day
        if day1 != dayOfChanges && ch.value
          # add first day of changes if not done yet
          unless day1Added
            committedPoints.push createDataPoint buildXAxis(day1.date),
                                                 {
                                                   name: "initial estimate",
                                                   value: day1.netVelocity,
                                                   change:{sprint: sprint}
                                                 },
                                                 day1.netVelocity,
                                                 "Begin Sprint"
            day1Added = true

          point = createDataPoint buildXAxis(dayOfChanges.date), ch, dayOfChanges.netVelocity, pc.action
          committedPoints.push point

          if ch.wasChange
            if change.sprintStory.wasAdded
              addedPoints.push point
            else
              changePoints.push point

          if ch.wasRemoved
            removedPoints.push point

    # Add data for END OF SPRINT
    committedPoints.push createDataPoint buildXAxis(new Date(sprint.endDate||new Date())),
                                        {
                                          name: "end of sprint",
                                          change:{sprint: sprint},
                                          value: sprint.missedTotalCommitment
                                        },
                                        sprint.missedTotalCommitment,
                                        "End Sprint"
    {
      committedPoints: committedPoints
      removedPoints: removedPoints
      changePoints: changePoints
      addedPoints: addedPoints
      changeDates: changeDates
    }

  showGraph: (sprint, series, useDateAsXAxis)=>

    highChartsOptions =
          chart:
              type: 'line'

          title:
              text: "<b>Burn down chart of</b> Board: <b>#{sprint.board.name}</b> Sprint: <b>#{sprint.name}</b>"

          subtitle:
              text: "from: #{@agiliticsUtils.dateFormat(sprint.startDate)} to: #{@agiliticsUtils.dateFormat(sprint.endDate)}"

          yAxis:
              min: 0
              title:
                  text: 'Story Points'

          tooltip:
              enabled: true
              formatter: ->
                change = this.point.change
                if change.change.sprint == sprint
                    "sprint: #{change.change.sprint.name} △(#{change.value}) #{this.point.change.name}"
                else
                  false

          plotOptions:
              line:
                  animation: false
                  dataLabels:
                      enabled: false
                  enableMouseTracking: true
              series:
                states:
                  hover:
                    enabled: true,
                    lineWidth: 5

          series: series

    if(useDateAsXAxis)
      highChartsOptions.xAxis =
          type: 'datetime',
          dateTimeLabelFormats:
              month: '%e. %b',
              year: '%b'

    $("#sprint-#{sprint.pid}").html("")
    $("<div style='height:500px;'></div>").appendTo("#sprint-#{sprint.pid}").highcharts highChartsOptions


  initOrGetDayOfChanges: (ldate, changeDates, day1, type )=>
      dstr = @agiliticsUtils.dateFormat(ldate)
      key = "#{dstr}-#{type == "initEstimate" }-"
      unless changeDates[key]
        changeDates[key] =
          dateStr: dstr
          date: ldate
          netValue: 0
          changes: []

      changeDates[key]

  storyOut = (change)-> "#{change.sprintStory.story.name}"
  parseOrZero = (val)-> parseInt(val) || 0

  changeProcessors: [
      action: 'initial_estimate'
      process: (change) ->
        name: "Initial Value for story #{storyOut(change)}"
        type: "initEstimate"
        value: parseOrZero change.newValue
        change: change
    ,
      action: 'changed_estimate'
      process: (change)->
        initValue = parseOrZero change.oldValue
        newValue = parseOrZero change.newValue
        name: "Changed Estimate from #{initValue} to #{newValue} : #{storyOut(change)}"
        type: "change"
        wasChange: true
        value: newValue - initValue
        change: change
    ,
      action: 'finished'
      process: (change)->
        name: "Finished story #{storyOut(change)}"
        type: "finish"
        burndown: true
        value: -1 * (parseOrZero change.currentStoryValue)
        change: change
    ,
      action: 'reopened'
      process: (change)->
        name: "Reopened story #{storyOut(change)}"
        type: "reopened"
        burndown: true
        value: (parseOrZero change.currentStoryValue)
        change: change
    ,
      action: 'added'
      process: (change)->
        name: "Added story #{storyOut(change)}"
        type: "change"
        wasChange: true
        value: parseOrZero change.initSize
        change: change
    ,
      action: 'removed'
      process: (change)->
        name: "Removed story #{storyOut(change)}"
        type: "remove"
        wasRemoved: true
        value: -1 * (parseOrZero change.sprintStory.size)
        change: change

  ]

  restrict: 'E'
  templateUrl: "views/directives/sprint-summary.html"
  scope: {
    sprint: "="
    colors: "="
  }