five = require 'johnny-five'
util = require 'util' 
EventEmitter = require('events').EventEmitter
spawn = require('child_process').spawn

class Camera extends EventEmitter

  constructor: (opts = {}) ->

    @tilt = new five.Servo 
      range: [70, 180]
      pin: 8

    @pan = new five.Servo
      pin: 7

    #@ffserver = spawn('ffserver', ['-f', 'config/ffserver.conf'])

  control: (pos) ->
    @pan.move (pos.x * 90) + 90
    @tilt.move 180 - ((pos.y * 90) + 90)

  record: ->

    @stream = spawn('/home/kelly/mjpg-streamer/mjpg-streamer/mjpg_streamer', ['-i', '"/home/kelly/mjpg-streamer/mjpg-streamer/input_uvc.so -n -f 15 -r 640x480"', '-o', '"/home/kelly/mjpg-streamer/mjpg-streamer/output_http.so -n -w /home/kelly/mjpg-streamer/mjpg-streamer/www"'])
    #@ffmpeg = spawn('ffmpeg',['-f','video4linux2','-i','/dev/video0', '-vcodec', 'libvpx', 'test2.avi'])

    @recording = true

    @stream.on "exit", (code) =>
      console.log "stream exited with code " + code  if code isnt 0
      @stream.stdin.end()
      @recording = false

  stop: ->
    if @recording then @stream.kill('SIGHUP')

module.exports = Camera