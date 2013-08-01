class @AgiliticsUtils

    dateFormat : (dstr) ->
      return "" unless dstr
      dmonths = [ "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" ]
      d = new Date(dstr)
      "#{d.getDate()}-#{dmonths[d.getMonth()]}-#{d.getFullYear()}"

    differenceInDays : (date1, date2)->
      timeDiff = Math.abs(date2.getTime() - date1.getTime())
      Math.ceil(timeDiff / (1000 * 3600 * 24))


module.factory('agiliticsUtils', [()-> new AgiliticsUtils()])
