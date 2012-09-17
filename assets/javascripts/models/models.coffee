Medibot.Models ||= {}

Medibot.Models.Joystick = Backbone.Model.extend
  defaults:
    [0, 0]
  initialize: ->
    @on 'change', (pos) ->
      Medibot.socket.emit 'control:move', pos

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
      angle: 0
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
    min: 0
    max: 255
		value: 0

  progress: ->
    @get('value') / @get('max')