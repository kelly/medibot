five = require 'johnny-five'
__ = require 'johnny-five/lib/fn.js'
_ = require 'underscore' 
util = require 'util' 
compulsive = require 'compulsive'
fs = require 'fs'
EventEmitter = require('events').EventEmitter

class Camera extends EventEmitter

  constructor: (opts = {}) ->

    @tilt = new five.Servo 
      range: [70, 180]
      pin: 8

    @pan = new five.Servo
      pin: 7


  control: (pos) ->
    for servo in [@pan, @tilt]
      servo.move (pos[_i] * 90) + 90

  record: ->

  stop: ->


module.exports = Camera