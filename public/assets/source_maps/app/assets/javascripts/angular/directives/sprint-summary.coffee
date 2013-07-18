module.directive('sprintSummary', [ "$http", "$timeout", ($http, $timeout) -> new SprintSummary($http, $timeout)])

class SprintSummary

  constructor: ($http, $timeout) ->
    @$timeout = $timeout

  createDataPoint = (date, change, velocity, action)->
    x: date
    y: velocity
    change: change
    action: action

  gotoSprint: (sprint)=>
    window.location.hash = "/sprints/#{sprint.pid}"

  link: (scope, element, attr) =>

    scope.gotoSprint = @gotoSprint

    scope.$watch "sprint", =>

      committedPoints = []
      removedPoints = []
      changePoints = []
      addedPoints = []

      if(scope.sprint)

        scope.sprints = scope.sprint.board.sprints
        sprint = scope.sprint
        scope.selectedSprint = sprint

        changeDates = {}
        velocity = 0
        sprint.changes = _.sortBy(sprint.changes, (c)-> new Date(c.time))
        sprintStartDate = new Date(sprint.startDate)
        for change in sprint.changes
          for pc in @changeProcessors when change.action.indexOf(pc.action) >= 0
            changeTime = new Date(change.time)

            continue unless changeTime >= sprintStartDate

            ch = pc.process(change)
            dayOfChanges = @initOrGetDayOfChanges(changeTime, changeDates, day1, ch.type)
            dayOfChanges.changes.push ch

            velocity += ch.value
            ch.netVelocity = velocity

            dayOfChanges.netValue += ch.value
            dayOfChanges.netVelocity = velocity

            day1 = dayOfChanges unless day1
            if day1 != dayOfChanges && ch.value
              unless day1Added
                committedPoints.push createDataPoint day1.date, { name: "initial estimate", value: day1.netVelocity }, day1.netVelocity, "Begin Sprint"
                day1Added = true

              point = createDataPoint dayOfChanges.date, ch, dayOfChanges.netVelocity, pc.action

              committedPoints.push point
              if ch.wasChange
                if change.sprintStory.wasAdded
                  addedPoints.push point
                else
                  changePoints.push point

              if ch.wasRemoved
                removedPoints.push point


        committedPoints.push createDataPoint new Date(sprint.endDate), {name: "end of sprint", value: sprint.missedTotalCommitment}, sprint.missedTotalCommitment, "End Sprint"

        cd = _.map(changeDates, (o,d)-> {date: o.dateStr, netValue: o.netValue, changes: o.changes, netVelocity: o.netVelocity} )
        scope.count = cd.length
        scope.changeDates = cd

        sg = => @showGraph sprint, [
          { type: "line", name: "committed", step: 'left', color: "green", marker:{ enabled: false }, data: committedPoints},
          { type: "scatter", name: "added", step: 'left', color: "black", marker:{ enabled: true, radius: 5 }, data: addedPoints},
          { type: "scatter", name: "changed", step: 'left', color: "gray",  marker:{ enabled: true, radius: 5 }, data: changePoints}
          { type: "scatter", name: "removed", step: 'left', color: "red",  marker:{ enabled: true, radius: 5 }, data: removedPoints}
        ]

        @$timeout(sg, 0)
    this

  dateFormat = (dstr) ->
        dmonths = [ "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" ]
        d = new Date(dstr)
        "#{d.getDate()}-#{dmonths[d.getMonth()]}-#{d.getFullYear()}"


  showGraph: (sprint, series)=>

      $("<div style='height:500px;'></div>").appendTo("#sprint-#{sprint.pid}").highcharts
            chart:
                type: 'line'

            title:
                text: "Board: <b>#{sprint.board.name}</b> Sprint: <b>#{sprint.name}</b>"

            subtitle:
                text: "from: #{dateFormat(sprint.startDate)} -> to: #{dateFormat(sprint.endDate)}"

            xAxis:
                type: 'datetime',
                dateTimeLabelFormats:
                    month: '%e. %b',
                    year: '%b'

            yAxis:
                min: 0
                title:
                    text: 'Story Points'

            tooltip:
                enabled: true
                formatter: ->
                  change = this.point.change
                  "△(#{change.value}) #{this.point.change.name}"

            plotOptions:
                line:
                    dataLabels:
                        enabled: false
                    enableMouseTracking: true

            series: series


  initOrGetDayOfChanges: (ldate, changeDates, day1, type)=>
      dstr = dateFormat(ldate)
      key = "#{dstr}-#{type == "initEstimate" }-"
      unless changeDates[key]
        changeDates[key] =
          dateStr: dstr
          date: ldate
          netValue: 0
          changes: []

      changeDates[key]

  storyOut = (change)-> "#{change.sprintStory.story.name} #{change.sprintStory.pid}"
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
        value: -1 * (parseOrZero change.sprintStory.size)
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
  templateUrl: "/assets/directives/sprint-summary.html"
  scope: {
    sprint: "="
  }
