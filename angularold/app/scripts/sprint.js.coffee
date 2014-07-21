## Place all the behaviors and hooks related to the matching controller here.
## All this logic will automatically be available in application.js.
## You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#$ ->
#
#  $.getJSON('/import/boards' ).success( (data)->
#      processBoards data
#    ).fail( -> alert('fail'))
#
#
#  getUrlParams = ->
#    params = {}
#    window.location.search.replace /[?&]+([^=&]+)=([^&]*)/g, (str, key, value) ->
#      params[key] = value
#
#    params
#
#  getUrlParam = (name)->
#    getUrlParams()[name]
#
#  processBoards = (boards) ->
#    if boards
#      html = "<hr><h1>BOARDS</h1><hr>"
#      html += processBoard board for board in boards when board.sprints
#      $("#here").append(html)
#
#  processBoard = (board)->
#    html = "<h1>#{board.name}</h1>"
#    html += "<table><tr>"
#    html += "<td>Sprint Name</td>"
#    html += "<td>Start Date</td>"
#    html += "<td>Initial Commitment</td>"
#    html += "<td>Total Commitment</td>"
#    html += "<td>Initial Velocity</td>"
#    html += "<td>Total Velocity</td></th>"
#
#    if board.sprints
#      for sprint in board.sprints
#        sprinthtml = "<tr>"
#        sprinthtml += showSprint sprint
#        sprinthtml += "</tr>"
#        html += sprinthtml
#
#    html += "</table>"
#    html
#
#  showSprint = (sprint)->
#    initCommitment = 0
#    totalCommitment = 0
#    initVelocity = 0
#    totalVelocity = 0
#
#    highlight = (should) ->
#      if should
#        'style="color:red; font-weight:bold;"'
#      else
#        'style="color:gray"'
#
#    displayDone = (curStory) ->
#      if curStory.done
#        "<span #{highlight(false)}>DONE</span>"
#      else
#        "<span #{highlight(true)}>NOT DONE</span>"
#
#    displaySize = (curStory) ->
#      style = highlight(true) unless curStory.size == curStory.init_size || curStory.was_added
#      "<span #{style}>#{curStory.size}, #{curStory.init_size}</span>"
#
#    indicateIfRemoved = (curStory) ->
#      if curStory.was_removed
#        "text-decoration:line-through"
#      else
#        ""
#
#    html = ""
##    html += "<ul>"
#    if sprint.stories
#      for curStory in sprint.stories
#        initCommitment += (curStory.init_size || 0) unless curStory.was_added
#        totalCommitment += (curStory.size || 0)
#        if curStory.done
#          initVelocity += (curStory.init_size || 0) unless curStory.was_added
#          totalVelocity += (curStory.size || 0)
#
##        html += "<li style=#{indicateIfRemoved(curStory)} >#{curStory.jid} : #{displayDone(curStory)} : #{displaySize(curStory)} #{if curStory.was_added then curStory.init_date else "" }</li>"
#
#
#    startDate = new Date(sprint.change_set.startTime)
#    month = startDate.getMonth() + 1
#    year =  startDate.getFullYear()
#    date =  startDate.getDate()
#    cols = []
#    cols.push "#{sprint.name}"
#    cols.push "#{month}/#{date}/#{year}"
#    cols.push "#{initCommitment}"
#    cols.push "#{totalCommitment}"
#    cols.push "#{initVelocity}"
#    cols.push "#{totalVelocity}"
#
#    html += "<td>#{col}</td>" for col in cols
#
##    html += "---- END SPRINT ---"
#    html