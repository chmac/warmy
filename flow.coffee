# We don't care about results, only flow control
# Inspired by http://book.mixu.net/node/ch7.html

flow = (limit, items, final, func) ->
  running = 0
  
  launcher = () ->
    while running < limit && items.length > 0
      item = items.shift()
      func item, ()->
        running--
        if items.length > 0
          launcher()
        else
          final?()
      running++
  
  launcher()

module.exports = flow