Medibot.Views ||= {}

class Medibot.Views.Hud extends Medibot.Views.Base

  className: 'hud'
  template: Handlebars.templates['hud']

  initialize: ->
    Medibot.socket = io.connect 'http://localhost'

    @sensorModel = new Medibot.Models.Sensor()
    @joystickModel = new Medibot.Models.Joystick
    @sonarModel = new Medibot.Models.Sonar()

    @notifications = new Medibot.Collections.Notifications

    Medibot.socket.on 'read', (data) =>
      # @setData data
      @sensorModel.set(data.sensor)
      @sonarModel.set(data.sonar)

  # setData: (data) ->

  render: ->

    @renderTemplate {}

    @$toolbar = @$('#toolbar')

    @renderChild new Medibot.Views.Sensor(
      model: @sensorModel
      radius: 30
    ), @$toolbar

    @renderChild new Medibot.Views.NotificationFooter 
      collection: @notifications

    @renderChild new Medibot.Views.Sonar(
      model: @sonarModel
      lineWidth: 1
      radius: 60
      digit: false
    ), @$toolbar

    @renderChild new Medibot.Views.BlockGraph(
      model: @sensorModel
      height: 20
      width: 120
      rows: 1
      cols: 10
      lineWidth: 1
      direction: 'right'
    ), @$toolbar

    @renderChild new Medibot.Views.Joystick
      model: @joystickModel
      width: 340
      height: 260
      lineWidth: 1
      digit: false

    @renderChild new Medibot.Views.Compass(
      model: @sensorModel
      lineWidth: 1
      radius: 70
    )

    @