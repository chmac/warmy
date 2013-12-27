# We don't care about results, only flow control

async = (item, next) ->
  console.log "Async called with item = %s", item
  setTimeout next, 1000

items = [1, 2, 3, 4, 5, 6, 7, 8]
running = 0
limit = 2

launcher = () ->
  while running < limit && items.length > 0
    item = items.shift()
    async item, ()->
      running--
      if items.length > 0
        launcher()
    running++

launcher()