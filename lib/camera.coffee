five = require 'johnny-five'
__ = require 'johnny-five/lib/fn.js'
_ = require 'underscore' 
util = require 'util' 
compulsive = require 'compulsive'
EventEmitter = require('events').EventEmitter

class Camera extends EventEmitter

  constructor: (opts = {}) ->

    @tilt = new five.Servo 
      range: [70, 180]
      pin: 8

    @pan = new five.Servo
      pin: 7

  move: (pos) ->
    for servo in [@pan, @tilt]
      if (pos[_i] <= servo.last.degrees - 5) || (pos[_i] => servo.last.degrees + 5)
        servo.move (pos[_i] * 90) + 90