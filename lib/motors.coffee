EventEmitter = require('events').EventEmitter
five = require 'johnny-five'
__ = require 'johnny-five/lib/fn.js'
_ = require 'underscore' 
util = require 'util' 
compulsive = require 'compulsive'

class Motors extends EventEmitter

  isMoving: false
  isTurning: false
  timer: false

  constructor: (opts) ->
    @right = new five.Motor(pins: opts.right)
    @left = new five.Motor(pins: opts.left)
    @speed = unless opts.speed then 100 else opts.speed
    @motors = new five.Motors();

  move: (right, left) ->
    @status 'moving'
    @right.move right
    @left.move left

  go: (direction) ->
    switch direction
      when 'forward' then speeds = [@speed, @speed]
      when 'reverse' then speeds = [-@speed, -@speed]
      when 'right' then speeds = [0, @speed]
      when 'left'then speeds = [@speed, 0]
    @move speeds

  accelerate: (speed = 255) ->
    @motors.accelerate(speed)

  decelerate: (speed = 0) ->
    @motors.decelerate(speed)

  turn: (angle) ->
    direction = if angle < 180 then 'left' else 'right'
    @go direction
    @status 'turning'

  control: (pos) ->
    clearTimeout(@timer)
    console.log pos
    speed = Math.abs(pos.y * 255) 
    diff = Math.abs(pos.x * speed)
    motors = if pos.x < 0 
      left: speed, right: speed - diff
    else
      left: speed - diff, right: speed
    #speed inverted
    if pos.y < 0
      motors.left *= -1
      motors.right *= -1 

    @move motors.right, motors.left

    @timer = setTimeout =>
      @decelerate()
    , 1000

  status: (type) ->
    @isMoving = false; @isTurning = false
    @emit type, null
    console.log type
    switch type
      when 'moving' then @isMoving = true
      when 'turning' then @isTurning = true

  stop: ->
    @move 0, 0
    @status 'stopped'

module.exports = Motors