path             = require 'path'
http             = require 'http'
express          = require 'express'
socketio         = require 'socket.io'
MultiRogueServer = require './server/MultiRogueServer'

console.log '=== MULTIROGUE SERVER ==='
console.log 'Setting up server...'

# set up app
app = express()
app.set 'port', process.env.PORT or 13375
app.use express.static path.join __dirname, 'public'

# create server
server = http.createServer app

# attach io to server (log only errors and warnings)
io = socketio.listen server, { 'log level': 1 }

# set up game server
multirogueServer = new MultiRogueServer io

# start listening for connections
server.listen app.get('port')
io.sockets.on 'connection', multirogueServer.handleConnection
console.log "Listening on port #{app.get('port')}."
