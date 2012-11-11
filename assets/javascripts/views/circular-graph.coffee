Medibot.Views ||= {}

class Medibot.Views.CircularGraph extends Medibot.Views.RaphaelBase
  className: 'circular-graph section'

  draw: ->
    value = @model.get('value')
    max = @model.get('max')
    
    unless value > max
      if @options.digit then @$digit.text(value)
      @circle.animate
        arc: [@center, @center, value, max, @options.radius]
      , 200, @options.animation

  render: ->
    super

    @bg = @paper.circle(@center, @center, @options.radius).attr
      stroke: @colors.bg
      "stroke-width": @options.lineWidth

    @circle = @paper.path().attr
      stroke: @colors.highlight
      "stroke-width": @options.lineWidth
      arc: [@center, @center, 0, 255, @options.radius]
    @