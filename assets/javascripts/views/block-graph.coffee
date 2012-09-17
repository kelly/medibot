Medibot.Views ||= {}

class Medibot.Views.BlockGraph extends Medibot.Views.RaphaelBase
  className: 'block-graph section'

  initialize: (@options = {}) ->
    super

    @options.spacing = @options.spacing || 4
    @options.direction = @options.direction || 'right'

  draw: ->
    progress = @model.progress()

    for row in [0..@options.rows - 1]
      for col in [0..@options.cols - 1]
        block = @blocks[row][col]
        opacity = block.attr('fill-opacity')

        if @options.direction == 'up'
          limit = Math.floor (@options.rows - (progress * @options.rows))

          colorCond = opacity < 1 && row >= limit 
          eraseCond = opacity > 0 && row <= limit

        if @options.direction == 'right'
          limit = Math.floor progress * @options.cols 

          colorCond = opacity < 1 && col <= limit 
          eraseCond = opacity > 0 && col >= limit

        if colorCond 
          block.animate
            'fill-opacity': 1
          , 200, @options.animation
        else if eraseCond
          block.animate
            'fill-opacity': 0
          , 200, @options.animation
            
    # @model.progress() / 

  render: ->
    super

    # create 2d array
    @blocks = new Array(@options.rows)
    for block in @blocks
      @blocks[_i] = new Array(@options.cols)

    # constrain block size to paper size
    blockWidth = Math.floor(@options.width / @options.cols) - @options.lineWidth  - @options.spacing
    blockHeight = Math.floor(@options.height / @options.rows) - @options.lineWidth - @options.spacing

    y = @options.spacing
    for row in [0..@options.rows - 1]
      x = @options.spacing
      for col in [0..@options.cols - 1]
        block = @paper.rect(x, y, blockWidth, blockHeight).attr
          stroke: @colors.bg
          fill: @colors.highlight
          'fill-opacity': 0
          'stroke-width': @options.lineWidth

        @blocks[row][col] = block
        x+= blockWidth + @options.spacing
      y+= blockHeight + @options.spacing
    @