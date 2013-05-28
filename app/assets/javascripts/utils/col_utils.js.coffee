window.colUtils =
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