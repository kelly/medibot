five = require 'johnny-five'
__ = require 'johnny-five/lib/fn.js'
_ = require 'underscore' 
util = require 'util' 
compulsive = require 'compulsive'
ffmpeg = require 'fluent-ffmpeg'
fs = require 'fs'
EventEmitter = require('events').EventEmitter

class Camera extends EventEmitter

  constructor: (opts = {}) ->

    @tilt = new five.Servo 
      range: [70, 180]
      pin: 8

    @pan = new five.Servo
      pin: 7

    @stream = fs.createWriteStream('/public/video.mjpeg')


  control: (pos) ->
    for servo in [@pan, @tilt]
      servo.move (pos[_i] * 90) + 90

  record: ->
    @ffmpeg = new ffmpeg(source: '/dev/video0')
      .addOption('-f', 'video4linxu2')
      .withVideoCodec('mjpeg')
      .withSize('640x480')
      .writeToStream(@stream, {})


module.exports = Camera