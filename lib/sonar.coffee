EventEmitter = require('events').EventEmitter
five = require 'johnny-five'
__ = require 'johnny-five/lib/fn.js'
_ = require 'underscore' 
util = require 'util' 

class Sonar extends EventEmitter

  history: []
  sweep: []

  constructor: (opts = {}) ->

    pins = opts.pins || [12, 4]
    @scanner = new five.Servo pins[0]
    @ping = new five.Ping pins[1]
    @steps = opts.steps || 20
    @min = opts.min || 10

    @ping.on 'read', =>
      # if collision 
      if @ping.inches < @min then @emit 'warning'

    @scanner.on 'move', =>
      if @isScanning 
        @sweep.push 
          degrees: if @scanner.last then @scanner.last.degrees else 0
          distance: @ping.inches

    @scanner.on 'finished', =>
      @scanner.stop().center()

      @history.push @sweep
      @emit 'scanned', null 
      @isScanning = false

  scan: ->
    @scanner.step @steps
    @isScanning = true

  module.exports = Sonar