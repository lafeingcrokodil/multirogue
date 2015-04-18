path         = require 'path'
http         = require 'http'
express      = require 'express'
debug        = require 'debug'
logger       = require 'morgan-debug'
bodyParser   = require 'body-parser'
cookieParser = require 'cookie-parser'
favicon      = require 'serve-favicon'
socketIO     = require 'socket.io'

MultiRogueServer = require './server/MultiRogueServer'

serverDebug = debug 'server'

serverDebug '=== MULTIROGUE SERVER ==='
serverDebug 'Setting up server...'

# set up app
app = express()
app.use favicon path.join(__dirname, 'public', 'favicon.ico')
app.use logger 'server', 'dev'
app.use bodyParser.json()
app.use bodyParser.urlencoded(extended: false)
app.use cookieParser()
app.use express.static path.join(__dirname, 'public')
app.set 'port', process.env.PORT or 13375

# create server
server = http.createServer app

# attach io to server
io = socketIO server

# set up game server
multirogueServer = new MultiRogueServer io

# start listening for connections
server.listen app.get('port'), ->
  serverDebug "Listening on port #{server.address().port}."
