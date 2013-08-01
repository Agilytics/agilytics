class @AgiliticsUtils

    dateFormat : (dstr) ->
      return "" unless dstr
      dmonths = [ "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" ]
      d = new Date(dstr)
      "#{d.getDate()}-#{dmonths[d.getMonth()]}-#{d.getFullYear()}"

    differenceInDays : (date1, date2)->
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
                ifAbsent: -> doItUnless(object[collectionName] && object[collectionName][name])
                now: -> doItUnless(false)



    push: (value)->
        into: (collectionName)->
             on: (object)->

                doItUnless = (shouldNot)->
                        object[collectionName] = [] unless object[collectionName]
                        object[collectionName].push value unless shouldNot
                        value

                unless: doItUnless
                now: -> doItUnless(false)

angular.module('agilytics').factory('agiliticsUtils', [()-> new AgiliticsUtils()])