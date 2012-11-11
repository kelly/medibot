five = require 'johnny-five'
__ = require 'johnny-five/lib/fn.js'
_ = require 'underscore' 
util = require 'util' 
compulsive = require 'compulsive'
fs = require 'fs'
EventEmitter = require('events').EventEmitter
spawn = require('child_process').spawn

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
    @ffmpeg = spawn('ffmpeg',['-f','video4linux2','-i','/dev/video0', '-vcodec', 'libvpx', 'test2.avi'])

    @recording = true

    @ffmpeg.on "exit", (code) =>
      console.log "ffmpeg exited with code " + code  if code isnt 0
      @ffmpeg.stdin.end()
      @recording = false

  stop: ->
    if @recording then @ffmpeg.kill('SIGHUP')

module.exports = Camera