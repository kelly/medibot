Medibot.Views ||= {}

class Medibot.Views.Sonar extends Medibot.Views.RaphaelBase

  className: 'sonar-graph section'

  draw: ->
    scanner = @model.get('scanner')
    ping = @model.get('ping')

    if ping.get('distance') < ping.get('max') 
      point = @paper.rect((ping.get('distance') / ping.get('max')) * @options.radius, @center - @options.lineWidth, 5, 5)
        .rotate(scanner.get('degrees'), @center, @center - @options.lineWidth)
        .attr 
          fill: @colors.highlight
          stroke: false

      point.animate
        opacity: 0
      , 5000, @options.animation, ->
        point.remove()

    @core.animate 
      'stroke-width' : 50
      'stroke-opacity': 0
    , 500, @options.animation, ->
      @attr
        'stroke-opacity' : 1
        'stroke-width' : 0

    @beam.animate
      transform: "R#{scanner.get('degrees')},#{@center},#{@center - @options.lineWidth}"
    , 1000

  render: -> 
    super

    @paper.setSize @center * 2, @center

    # beam
    scanner = @model.get('scanner')
    range = scanner.get('range')
    steps = scanner.get('steps')

    @beam = @paper.sector(@center, @center - @options.lineWidth, @options.radius, range[1] - steps, range[1]).attr
      fill: @colors.transparent  
      stroke: false

    # source
    @core = @paper.sector(@center, @center - @options.lineWidth, 5, range[0], range[1]).attr
      fill: @colors.highlight
      stroke: @colors.highlight
      'stroke-width': 0
      'stroke-opacity': 0.2

    # grid
    for sector in _.range(@options.radius, 10, -10)
      @paper.sector(@center, @center - @options.lineWidth, sector, range[0], range[1]).attr
        stroke: @colors.bg
        'stroke-width': 1
        'stroke-opacity': 1

    @