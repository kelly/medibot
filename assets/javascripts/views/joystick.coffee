Medibot.Views ||= {}

Medibot.fn = {}
Medibot.fn.constrain = (x, lower, upper)  ->
  (if x <= upper and x >= lower then x else ((if x > upper then upper else lower)))

class Medibot.Views.Joystick extends Medibot.Views.RaphaelBase
  className: 'joystick'

  events:
    'click .button' : 'sourceChange'

  initialize: (@options = {}) ->
    $parent = $('.video-container')

    _.defaults @options,
      animation: "<>"
      lineWidth: 8
      digit: true
      frequency: 100

    $(window).on 'resize', =>
      $parent = $(@options.div)
      @resize $parent.width(), $parent.height()

  start: =>
    @control.animate
      fill: @colors.highlight2
    , 300, '<>'

    # @timer = setInterval =>
    #   @trigger 'move', @pos
    # , @options.frequency

  move: (dx, dy) =>

    hWidth = @options.width / 2
    hHeight = @options.height / 2

    dx = Medibot.fn.constrain dx, -hWidth, hWidth
    dy = Medibot.fn.constrain dy, -hHeight, hHeight

    pos = x: (dx / hWidth), y: (dy / hHeight)
    @model.set pos: pos

    @control.attr
      cx: @cx + dx
      cy: @cy + dy

  end: =>
    # clearInterval @timer
    @control.animate
      cx: @cx
      cy: @cy
      fill: @colors.highlight
    , 200, 'backOut'

  sourceChange: (evt) ->
    @model.set(sourceOn: $('.buttons li').index $(evt.target).parent())

  render: ->
    super

    sources = @model.get 'sources'
    @$el.append "<ul class='buttons'><li><a href='#' class='button #{sources[0]}-button'>
                 #{sources[0]}</a></li><li><a href='#' class='button #{sources[1]}-button'>#{sources[1]}</a></li></ul>"

    @bg = @paper.rect(0, 0, @options.width, @options.height).attr
      stroke: @colors.bg
      'stroke-width': @lineWidth

    @home = @paper.circle(@cx, @cy, 30).attr
      fill: @colors.bg
      stroke: false

    @control = @paper.circle(@cx, @cy, 30).attr
      stroke: false
      fill: @colors.highlight
      opacity: 0.7
      "stroke-width": @options.lineWidth

    @control.drag(@move, @start, @end)

    @