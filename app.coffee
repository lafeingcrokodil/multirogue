io      = require 'socket.io'
path    = require 'path'
http    = require 'http'
express = require 'express'

app = express()
app.use express.static path.join __dirname, 'public'

server = http.createServer app
io = io.listen server
io.set 'log level', 2

server.listen 13375

io.sockets.on 'connection', (socket) ->
  socket.emit 'display', {
    char: '@'
    x: 0
    y: 0
  }
