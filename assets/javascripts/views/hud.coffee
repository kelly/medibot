Medibot.Views ||= {}

class Medibot.Views.Hud extends Medibot.Views.Base

  className: 'hud'
  template: Handlebars.templates['hud']

  initialize: ->
    Medibot.socket = io.connect 'http://192.168.0.186'

    @battery       = new Medibot.Models.Sensor min: 410, max: 565
    @motorLeft     = new Medibot.Models.Motor
    @motorRight    = new Medibot.Models.Motor
    @sonar         = new Medibot.Models.Sonar
    @notifications = new Medibot.Collections.Notifications

    Medibot.socket.on 'read', (data) =>
      @battery.set(data.battery)
      @sonar.get('ping').set(data.sonar.ping)
      @sonar.get('scanner').set(data.sonar.scanner)
      @motorLeft.set('value', data.motors.left)
      @motorRight.set('value', data.motors.right)

    if @pad = Gamepads.get(0)
      @initPad()
    else 
      @joystick = new Medibot.Models.Joystick


  initPad: ->

    normalize = (axis) ->
      # maxing out at 220 instead of 255, just too fast for indoors
      Math.round(axis * 220)

    map = (button) ->
      dir = 
        switch button
          when 'BUTTON_12' then 'up'
          when 'BUTTON_13' then 'down'
          when 'BUTTON_14' then 'left'
          when 'BUTTON_15' then 'right'

    @pad.on 'buttondown', (evt) ->
      if dir = map evt.button
        Medibot.socket.emit "camera:move", dir

      if evt.button == 'BUTTON_0'
        Medibot.socket.emit "motors:move", [0,0]

    @pad.on 'buttonup', (evt) ->
      if dir = map evt.button
        Medibot.socket.emit "camera:move:end", dir

    @pad.on 'axismove', (evt) =>
      if evt.button == 'AXE_1' || evt.button == 'AXE_3'
        Medibot.socket.emit "motors:move", [normalize(@pad.AXE_1), normalize(@pad.AXE_3)]

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

    if @joystick
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