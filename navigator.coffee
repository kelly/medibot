five = require 'johnny-five'
util = require 'util' 
medibot = require './lib/medibot.js'
express = require 'express'
app = express.createServer()

io = require('socket.io').listen(app)
# io = require('socket.io').listen(app).set('log level', 1);

# Start Express

app.set('views', __dirname + '/assets/templates');
app.set('view engine', 'hbs');

app.configure(() ->
  app.set 'views', "#{__dirname}/assets/templates"
  app.use express.logger()
  app.use express.bodyParser()
  app.use app.router
  app.use express.methodOverride()
  app.use(express.static(__dirname + '/public'))
  hbsPrecompiler = require('handlebars-precompiler')
  hbsPrecompiler.watchDir(
    __dirname + "/assets/templates",
    __dirname + "/public/javascripts/medibot-templates.min.js",
    ['handlebars', 'hbs']
  );
)

app.get '/', (req, res) ->
  res.render 'index',
    locals:
      title: 'medibot'

# arduino connected code
board = new five.Board()

board.on "ready", ->

  bot = new medibot.Bot autonomous: false

  io.sockets.on "connection", (client) ->

    bot.start()
    bot.camera.record()

    client.on 'drive', ->
      bot.drive()


    bot.on 'read', ->
      client.emit 'read', bot.last
    
    # client.on 'motors:move', (pos) ->
    #   bot.motors.move pos

    client.on 'camera:move', (pos) ->
      bot.camera.move pos

# testing code
# io.sockets.on "connection", (client) ->
#   console.log "connected"
#   i = 0
#   angle = 0
#   setInterval ->
#     client.emit 'read', 
#       sensor:
#         value: Math.floor(Math.random() *255)
#       sonar:
#         scanner: 
#           degrees: Math.floor(Math.random() *255)
#         ping:
#           distance: Math.floor(Math.random() * 50)
#           min: 0
#           max: 50
#     angle += 20
#   , 1000
#   client.on 'camera:move', (pos) ->
#     console.log 'camera: ' + pos.x + ' ' + pos.y

#   client.on 'motors:move', (pos) ->
#     if pos[0] < 0
#       left = pos[0] * 255
#     normalized = pos[0]

#     console.log 'motors: ' + pos.x + ' ' + pos.y

    
unless module.parent
  app.listen 3001
  console.log "Server started on port " + 3001