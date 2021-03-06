Medibot.Models ||= {}

Medibot.Models.Joystick = Backbone.Model.extend
  defaults:
    sensitivity: 0.01
    sources: ['camera', 'motors']
    sourceOn: 0
    last:
      x: 0
      y: 0
    pos: 
      x: 0
      y: 0

  initialize: ->

    @on 'change:pos', ->
      last = @get('last')
      sens = @get('sensitivity')
      pos = @get('pos')

      Medibot.socket.emit "#{@source()}:move", pos
      @set('last', pos)

      # if (pos.x < last.x - sens) || (pos.y < last.y - sens) || (pos.x > last.x + sens) || (pos.y > last.y + sens)
      #   Medibot.socket.emit "#{@source()}:move", pos
      #   @set('last', pos)

  source: ->
    @get('sources')[@get('sourceOn')]

Medibot.Models.Compass = Backbone.Model.extend
	defaults:
		heading: 0
		bearing: 'North'
		raw: {x: 0, y: 0, z: 0}
		scaled: {x: 0, y: 0, z: 0}

Medibot.Models.Scanner = Backbone.Model.extend
  defaults:
    steps: 20
    range: [0, 180]
    degrees: 0

Medibot.Models.Ping = Backbone.Model.extend
  defaults:
    distance: 0
    min: 0
    max: 140

Medibot.Models.Sonar = Backbone.Model.extend
  defaults:
    ping: {}
    scanner: {}

  initialize: ->
    @set('scanner', new Medibot.Models.Scanner)
    @set('ping', new Medibot.Models.Ping)

    @get('scanner').on 'change', => @trigger('change')
    @get('ping').on 'change', => @trigger('change')


Medibot.Models.Notification = Backbone.Model.extend
  defaults:
    body: ''
    type: 'default'
    timestamp: Date.now()
    priority: 0

Medibot.Models.Motor = Backbone.Model.extend
  defaults:
    min: 0
    max: 255
    value: 0
  progress: ->
    @get('value') / @get('max')

Medibot.Models.Sensor = Backbone.Model.extend
	defaults:
    min: 410
    max: 565
		value: 0

  progress: ->
    @get('value') / @get('max')