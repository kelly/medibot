$.fn.animationComplete = (callback) ->
  if Modernizr.cssanimations
    animationEnd = "animationend webkitAnimationEnd"
    $(@).one animationEnd, callback if $.isFunction(callback)      
  else
    setTimeout callback, 0
    $(@)

$.fn.animateCSS = (animation, callback) ->
  animation or (animation = "none")
  $(@).addClass("animated " + animation).animationComplete ->
    $(@).removeClass "animated " + animation
    callback() if callback
  $(@)

window.requestAnimFrame = (->
  window.requestAnimationFrame or window.webkitRequestAnimationFrame or window.mozRequestAnimationFrame or window.oRequestAnimationFrame or window.msRequestAnimationFrame or (callback) ->
    window.setTimeout callback, 1000 / 60
)()

$('body').on "touchmove", (evt) ->
  evt.preventDefault()