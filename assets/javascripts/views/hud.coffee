Medibot.Views ||= {}

class Medibot.Views.Hud extends Medibot.Views.Base

  className: 'hud'
  template: Handlebars.templates['hud']

  initialize: ->
    Medibot.socket = io.connect 'http://192.168.0.192'

    @battery       = new Medibot.Models.Sensor min: 410, max: 565
    @joystick      = new Medibot.Models.Joystick
    @motorLeft     = new Medibot.Models.Motor
    @motorRight    = new Medibot.Models.Motor
    @sonar         = new Medibot.Models.Sonar
    @notifications = new Medibot.Collections.Notifications

    Medibot.socket.on 'read', (data) =>
      @battery.set(data.battery)
      @sonar.set(data.sonar)
      @motorLeft.set('value', data.motors.left)
      @motorRight.set('value', data.motors.right)

  render: ->

    @renderTemplate {}

    @$toolbar = @$('.toolbar')
    @$video = @$('.video-container')

    @renderChild new Medibot.Views.Sensor(
      model: @battery
      radius: 20
      digit: false
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
      model: @motorLeft
      height: 20
      width: 120
      rows: 1
      cols: 10
      lineWidth: 1
      label: "Motor L"
      direction: 'right'
    ), @$toolbar

    @renderChild new Medibot.Views.BlockGraph(
      model: @motorRight
      height: 20
      width: 120
      rows: 1
      cols: 10
      lineWidth: 1
      label: "Motor R"
      direction: 'right'
    ), @$toolbar

    @renderChild new Medibot.Views.Joystick(
      model: @joystick
      $parent: @$video
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