# We don't care about results, only flow control

module.exports = (limit, async, items) ->
  running = 0
  
  launcher = () ->
    while running < limit && items.length > 0
      item = items.shift()
      async item, ()->
        running--
        if items.length > 0
          launcher()
      running++
  
  launcher()