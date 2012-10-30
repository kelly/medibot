Medibot.Models ||= {}

Medibot.Models.Joystick = Backbone.Model.extend
  defaults:
    sensitivity: 0.05
    sources: ['camera', 'motors']
    sourceOn: 0
    last:
      x: 0
      y: 0
    pos: 
      x: 0
      y: 0

  initialize: ->

    @on 'change', ->
      last = @get('last')
      sens = @get('sensitivity')
      pos = @get('pos')

      if (pos.x < last.x - sens) || (pos.y < last.y - sens) || (pos.x > last.x + sens) || (pos.y > last.y + sens)
        Medibot.socket.emit "#{@source()}:move", @normalize()
        @set('last', pos)

  normalize: ->
    pos = @get('pos')

    if @source() == 'camera'
      norm.y = (pos.y * 90) + 90
      norm.x = (pos.x * 90) + 90

    return norm

  source: ->
    @get('sources')[@get('sourceOn')]

Medibot.Models.Compass = Backbone.Model.extend
	defaults:
		heading: 0
		bearing: 'North'
		raw: {x: 0, y: 0, z: 0}
		scaled: {x: 0, y: 0, z: 0}

Medibot.Models.Sonar = Backbone.Model.extend
  defaults:
    scanner:
      steps: 20
      range: [0, 180]
      degrees: 0
    ping:
      distance: 0
      min: 0
      max: 140

Medibot.Models.Notification = Backbone.Model.extend
  defaults:
    body: ''
    type: 'default'
    timestamp: Date.now()
    priority: 0

Medibot.Models.Motor = Backbone.Model.extend
	defaults:
		left: 0
		right: 0

Medibot.Models.Sensor = Backbone.Model.extend
	defaults:
    min: 410
    max: 565
		value: 0

  progress: ->
    @get('value') / @get('max')