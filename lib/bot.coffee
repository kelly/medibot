five = require 'johnny-five'
__ = require 'johnny-five/lib/fn.js'
_ = require 'underscore' 
util = require 'util' 
compulsive = require 'compulsive'
EventEmitter = require('events').EventEmitter
medibot = require '../lib/medibot.js'

class Bot extends EventEmitter

  history: []
  heading: 0
  last: {}
  servos: []

  constructor: (opts = {}) ->
    @autonomous = opts.autonomous || false

    @motors = new medibot.Motors
      speed: opts.speed || 100
      right: [3, 11]
      left: [5, 6]

    @sonar   = new medibot.Sonar()
    @camera  = new medibot.Camera()
    @battery = new five.Battery pin: 'A0'
    @compass = new five.Magnetometer()

    @battery.on 'warning', =>
      @stop()
      @_status 'warning: low power: #{@value}'

    @sonar.on 'warning', =>
      if @motors.isMoving 
        @motors.stop()
        @sonar.scan()

    @sonar.on 'scanned', =>
      ping = _.max @sonar.sweep, (ping) ->
        ping.distance

      heading = @heading
      heading -= 90 - ping.degrees
      if heading > 360 
        heading = heading - 360 
      else if heading < 0
        heading = 360 + heading

      console.log "current heading: #{@heading}, new heading: #{heading}"

      @turn heading

  start: ->
    
    five.Servos().center()

    if @autonomous
      # kick things off with a sonar scan
      @sonar.scan()

      # determine heading. Take an average of readings
      @repeat 30, 100, =>
        @heading = (@heading + @compass.heading) / 2

    # emit current sensor readings
    @loop 200, =>
      @_read()

  drive: (control) ->
    # @_status "moving #{direction}"
    # if speed then @motors.setSpeed speed
    # @motors.go direction
  
  turn: (heading) ->
    @motors.turn 'heading'
    @loop 100, (control) =>
      if @compass.heading >= heading - 5 && @compass.heading <= heading + 5
        @heading = heading
        @motors.go 'forward'
        control.stop()

  stop: ->
    @motors.decelerate(0)

  _status: (msg) ->
    @emit 'notification', msg

  _read: ->
    @last =
      timestamp: Date.now()
      sonar: 
        scanner: 
          degrees: if @sonar.scanner.last then @sonar.scanner.last.degrees else false 
        ping: 
          distance: @sonar.ping.inches
      battery: _.pick @battery, 'min', 'max', 'value'
      motors: 
        left: @motors.left.value
        right: @motors.right.value
      compass: @compass.bearing
    
    @history.push @last
    @emit 'read', null

["wait", "loop", "repeat", "queue"].forEach (api) ->
  Bot::[api] = compulsive[api]

module.exports = Bot