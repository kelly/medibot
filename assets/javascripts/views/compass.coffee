Medibot.Views ||= {}

class Medibot.Views.Compass extends Medibot.Views.RaphaelBase
  className: 'compass section'

  draw: ->
    @paper

  render: ->
    super

    @paper.circle(@center, @center, @options.radius).attr
      stroke: @colors.bg
      'stroke-width': @options.lineWidth
      'stroke-dasharray': '--'
      'stroke-linecap': 'butt'
      # 'stroke-linejoin': 'miter'

    @paper.path('M23.383,0C19.415,0,0,70.15,0,70.15l23.383-23.384L46.767,70.15C46.767,70.15,27.352,0,23.383,0z')

    @