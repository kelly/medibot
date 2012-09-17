express = require 'express'
app = express.createServer()
fs = require 'fs'
five = require("johnny-five")

io = require('socket.io').listen(app)
# board = new five.Board()

heading = 0;

# board.on "ready", ->

#   mag = new five.Magnetometer()
#   mag.on "headingchange", ->
#     heading = Math.floor @heading
    # console.log "heading", Math.floor(@heading)

  # mag.on "read", (err, timestamp) ->
  #   console.log @bearing

  # battery = new five.Battery('A0')

  # battery.on "read", (err, value) ->
  #   console.log "read", value

  # battery.on "change", (err, value) ->
  #   console.log "Battery is " + value
  
  # ping = new five.Ping(4)

  # ping.on "read", (err, value) ->
  #   console.log "Ping " + typeof @inches
  #   console.log "Object is " + @inches + "inches away"

  # motorL = new five.Motor [3, 11]
  # battery = new five.Sensor 
  #   pin: "A0",
  #   freq: 1000

  # motorR = new five.Motor [5, 6]

  # battery.on "change", (err, value) ->
  #   console.log "battery is " + value

  # motorR.on "read", (err, value) ->
  #   console.log "Motor R amps is " + value

  # motorR.move 100
  # motorR.decelerate 40
  # motorR.move 90 

  # setTimeout ->
  #   motorL.stop()
  #   # motorR.stop()
  # , 5000

  # servo0 = new five.Servo
  #   pin: 12

  # board.repl.inject
  #   servo0: servo0

  # servo1 = new five.Servo
  #   pin: 7

  # servo0.on 'finished', (err, value) ->
  #   console.log "finished"

  # board.repl.inject
  #   servo1: servo1

  # servo2 = new five.Servo
  #   range: [90, 180]
  #   pin: 8

  # board.repl.inject
  #   servo2: servo2


app.set('views', __dirname + '/views');
app.set("view engine", "hbs");

app.configure(() ->
  app.set 'views', "#{__dirname}/views"
  app.use express.logger()
  app.use express.bodyParser()
  app.use express.cookieParser()
  app.use app.router
  app.use express.methodOverride()
	app.use(express.static(__dirname + '/public'))
  hbsPrecompiler = require('handlebars-precompiler')
  hbsPrecompiler.watchDir(
    __dirname + "/assets/templates",
    __dirname + "/public/javascripts/medibot-templates.js",
    ['handlebars', 'hbs']
  );
)

app.get '/', (req, res) ->
	res.render 'index',
		locals:
			title: 'Home'
			
io.sockets.on "connection", (client) ->
  # motors = new arduino.Motors board: board
  # motors.move(100,100)
  
  setInterval ->
    client.emit 'sensor', { value: Math.floor(heading++) }
  , 500
  
  client.on 'flush', ->
    console.log 'flush'
    
  client.on 'brake', (motors) ->
    # implement
    
  client.on 'move', (motors) ->
    # console.log(motors)
  
io.sockets.on 'disconnect', ->
  # socket.end()
      
unless module.parent
  app.listen 3002
  console.log "Server started on port " + 3002