Medibot.Views ||= {}

Medibot.Views.Base = Backbone.View.extend

  showFor: (seconds, isPersistent) ->
    @show @animation, =>
      timer = setTimeout => 
        @hide()
      , seconds * 1000
      @$el.on 'mouseover',  =>
        clearTimeout timer
      @$el.on 'mouseleave', =>
        @hide()
        # TODO: remove these events? 
    @
  
  renderChild: (view, $div) ->
    $div ||= @$el
    $div.append(view.render().el)  
  
  toggle: ->
    if @isVisible then @hide() else @show()

  show: (animation, callback) -> 
    @animation = animation or @animation
    @animate @animation
    @on 'animation:complete', =>
      @isVisible = true
      @trigger 'visibility:showing'
      @$el.addClass('active')
      if callback then callback()
    # TODO: return @
  
  hide: (animation = @reverseAnimation(@animation), callback) -> 
    if @isVisible && !@isAnimating # only animate when the view isn't animating, and is visible.
      @animate animation
      @on 'animation:complete', =>
        @isVisible = false
        @$el.removeClass('active')
        @trigger 'visibility:hidden'
        if callback then callback()

  transition: (transition) ->
    @transition = transition or @transition
    @trigger 'transition:started'
    @$el.transitionCSS transition, =>
      @$el.addClass('active')
      @trigger 'transition:complete'      
  
  animate: (animation) ->
    unless @isAnimating
      @isAnimating = true
      @trigger 'animation:started'
      @$el.animateCSS animation, =>
        @isAnimating = false
        @trigger 'animation:complete'

  reverseAnimation: (str = '') ->
    matchList = ['Out', 'In', 'Down', 'Up', 'Right', 'Left']
    reverseList = ['In', 'Out', 'Up', 'Down', 'Left', 'Right']  
    newStr = str
    (if str.indexOf(item) != -1 then newStr = newStr.replace(item, reverseList[_i])) for item in matchList 
    newStr

Medibot.Views.RaphaelBase = Backbone.View.extend

  tagName: 'div'

  colors:
    bg: 'rgb(26, 56, 59)'
    highlight: 'rgb(64, 215, 220)'
    highlight2: 'rgba(255, 102, 124)'
    transparent: 'rgba(64, 215, 220, 0.1)'
    invisible: 'rgba(64, 215, 220, 0)'
    warning: 'rgba(244, 54, 6)'
    glow: 'rgb(35,41,37)'

  # styles:
    # glow:
    #     width: 0
    #     fill: false
    #     offsety: 0
    #     color: 'rgb(35,41,37)'

  initialize: (@options = {}) ->
    _.bindAll @, 'draw'
    @model.on 'change', @draw

    _.defaults @options,
      animation: "<>"
      lineWidth: 8
      digit: true

  render: ->
    if @options.radius 
      @center = @options.radius + @options.lineWidth
      @paper = Raphael(@el, @center * 2, (@center * 2))
    else 
      @cx = (@options.width / 2) + (@options.lineWidth * 2)
      @cy = (@options.height / 2) + (@options.lineWidth * 2)
      @paper = Raphael(@el, @options.width, @options.height)

    if @options.digit
      @$el.append '<p class="digit">0</p>'
      @$digit = @$('.digit')  

    # from http://stackoverflow.com/questions/5061318/drawing-centered-arcs-in-raphael-js
    @paper.customAttributes.arc = (cx, cy, value, total, R) ->
      alpha = 360 / total * value
      a = (90 - alpha) * Math.PI / 180
      x = cx + R * Math.cos(a)
      y = cy - R * Math.sin(a)
      if total is value
        path = [["M", cx, cy - R], ["A", R, R, 0, 1, 1, cx - 0.01, cy - R]]
      else
        path = [["M", cx, cy - R], ["A", R, R, 0, +(alpha > 180), 1, x, y]]
      path: path