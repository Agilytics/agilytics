class @AgiliticsUtils

  toPercent: (i)->
    p = Math.round(i * 100)
    p

  moveAndSort: (fromCollection, toCollection, item)->
    for s, i in fromCollection
      if s.id == item.id
        fromCollection.splice(i, 1)
        toCollection.push item
        sprints = _.sortBy(toCollection, (s)->
          s.id)
        toCollection.length = 0
        for item in sprints
          toCollection.push item
        break

  makeUTCObject : (date)->
    dateObj = new Date(date)

    yyyy = dateObj.getUTCFullYear()
    mm = dateObj.getUTCMonth() + 1
    mm = '0' + mm if mm.length = 1
    dd = dateObj.getUTCDate()
    dd = '0' + dd if dd.length = 1

    { utc: Date.UTC(yyyy, mm, dd), str: "#{mm}/#{dd}/#{yyyy}" }

  dateFormat: (dstr) ->
    return "" unless dstr
    dmonths = [ "January", "February", "March", "April", "May", "June", "July", "August", "September", "October",
                "November", "December" ]
    d = new Date(dstr)
    "#{d.getDate()}-#{dmonths[d.getMonth()]}-#{d.getFullYear()}"

  differenceInDays: (date1, date2)->
    timeDiff = Math.abs(date2.getTime() - date1.getTime())
    Math.ceil(timeDiff / (1000 * 3600 * 24))

  # add as to on
  add: (value)->
    as: (name) ->
      to: (collectionName)->
        on: (object) ->
          doItUnless = (shouldNot)->
            object[collectionName] = {} unless object[collectionName]
            object[collectionName][name] = value unless shouldNot
            object[collectionName][name]

          unless: doItUnless
          ifAbsent: ->
            doItUnless(object[collectionName] && object[collectionName][name])
          now: ->
            doItUnless(false)



  push: (value)->
    into: (collectionName)->
      on: (object)->
        doItUnless = (shouldNot)->
          object[collectionName] = [] unless object[collectionName]
          object[collectionName].push value unless shouldNot
          value

        unless: doItUnless
        now: ->
          doItUnless(false)

angular.module('agilytics').factory('agiliticsUtils', [ -> new AgiliticsUtils() ])