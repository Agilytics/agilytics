# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->

  processAndShowChanges = (changes)->
    showProcessedChanges( processMetrics changes )

  getUrlParams = ->
    params = {}
    window.location.search.replace /[?&]+([^=&]+)=([^&]*)/g, (str, key, value) ->
      params[key] = value

    params

  getUrlParam = (name)->
    getUrlParams()[name]

  $.getJSON('/sprint/changes?sprintId=' + getUrlParam "sprintId" ).success(processAndShowChanges).fail( -> alert('fail'))

  processMetrics = (changes)->
    ch = changes.changes
    objs = {}

    for k,v of ch
      o1 = v[0]

      objs[o1.key] = {isInitialized: false, wasAdded: false} unless objs[o1.key]

      curStory = objs[o1.key]

      if o1.statC && o1.statC.newValue
        curStory.size = o1.statC.newValue

      if o1.statC && ( o1.statC.newValue || o1.statC.noStatsValue )
        unless curStory.isInitialized
          if o1.statC.noStatsValue
            curStory.initSize = 0
          else
            curStory.initSize = o1.statC.newValue || curStory.size
          curStory.isInitialized = true

      if o1.column
        curStory.done = !o1.column.notDone

      if o1.added
        storyAddedDate = parseInt k
        curStory.initDate = new Date storyAddedDate
        curStory.wasAdded = storyAddedDate > changes.startTime
        curStory.wasRemoved = false

      if o1.added == false
        curStory.wasRemoved = true

    objs

  showProcessedChanges = (objs)->
    initCommitment = 0
    totalCommitment = 0
    initVelocity = 0
    totalVelocity = 0

    highlight = (should) ->
      if should
        'style="color:red; font-weight:bold;"'
      else
        'style="color:gray"'

    displayDone = (curStory) ->
      if curStory.done
        "<span #{highlight(false)}>DONE</span>"
      else
        "<span #{highlight(true)}>NOT DONE</span>"

    displaySize = (curStory) ->
      style = highlight(true) unless curStory.size == curStory.initSize || curStory.wasAdded
      "<span #{style}>#{curStory.size}, #{curStory.initSize}</span>"

    indicateIfRemoved = (curStory) ->
      if curStory.wasRemoved
        "text-decoration:line-through"
      else
        ""

    html = ""
    for k,v of objs
      curStory = v
      initCommitment += (curStory.initSize || 0) unless curStory.wasAdded
      totalCommitment += (curStory.size || 0)
      if curStory.done
        initVelocity += (curStory.initSize || 0) unless curStory.wasAdded
        totalVelocity += (curStory.size || 0)

      html += "<li style=#{indicateIfRemoved(curStory)} >#{k} : #{displayDone(curStory)} : #{displaySize(curStory)} #{if curStory.wasAdded then curStory.initDate else "" }</li>"

    $("#total").html "Initial Commitment: #{initCommitment}, TotalCommitment: #{totalCommitment} <br>"
    $("#total").append "Initial Velocity: #{initVelocity}, TotalVelocity: #{totalVelocity} <br>"
    $("#here").append(html)

