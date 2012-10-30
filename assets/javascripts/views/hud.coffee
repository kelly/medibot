Medibot.Views ||= {}

class Medibot.Views.Hud extends Medibot.Views.Base

  className: 'hud'
  template: Handlebars.templates['hud']

  initialize: ->
    Medibot.socket = io.connect 'http://localhost'

    @battery       = new Medibot.Models.Sensor min: 410, max: 565
    @joystick      = new Medibot.Models.Joystick()
    @sonar         = new Medibot.Models.Sonar ping: { min: 0, max: 140 }
    @notifications = new Medibot.Collections.Notifications()

    Medibot.socket.on 'read', (data) =>
      # @setData data
      @battery.set(data.battery)
      @sonar.set(data.sonar)

  # setData: (data) ->

  render: ->

    @renderTemplate {}

    @$toolbar = @$('.toolbar')
    @$video = @$('.video-container')

    @renderChild new Medibot.Views.Sensor(
      model: @battery
      radius: 20
      digit: true
      label: 'Battery'
    ), @$toolbar

    @renderChild new Medibot.Views.NotificationFooter 
      collection: @notifications

    @renderChild new Medibot.Views.Sonar(
      model: @sonar
      lineWidth: 1
      radius: 90
      digit: false
      label: 'Sonar'
    ), @$toolbar

    @renderChild new Medibot.Views.BlockGraph(
      model: @battery
      height: 20
      width: 120
      rows: 1
      cols: 10
      lineWidth: 1
      direction: 'right'
    ), @$toolbar

    @renderChild new Medibot.Views.Joystick(
      model: @joystick
      div: '.video-container'
      width: 640
      height: 320
      lineWidth: 1
      digit: false
    ), @$video

    # @renderChild new Medibot.Views.Compass(
    #   model: @sensorModel
    #   lineWidth: 1
    #   radius: 70
    # )

    @