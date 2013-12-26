fs = require 'fs'

class MultiRogueServer
  module.exports = MultiRogueServer

  rogues: []

  screenWidth: 80
  screenHeight: 24

  constructor: ->
    do @initializeScreen
    keyCodeStr = fs.readFileSync 'server/keyCodes.json', 'utf8'
    @keyCodes = JSON.parse keyCodeStr

  initializeScreen: =>
    @screen = []
    for x in [1..@screenWidth]
      column = []
      for y in [1..@screenHeight]
        column.push '.'
      @screen.push column

  handleConnection: (socket) =>
    rogue = @addRogue socket
    socket.on 'key', @handleKeyEvent(rogue)

  handleKeyEvent: (rogue) => (code) =>
    switch code
      when @keyCodes.H, @keyCodes.NUMPAD_4
        @move rogue, -1, 0
      when @keyCodes.L, @keyCodes.NUMPAD_6
        @move rogue, 1, 0
      when @keyCodes.K, @keyCodes.NUMPAD_8
        @move rogue, 0, -1
      when @keyCodes.J, @keyCodes.NUMPAD_2
        @move rogue, 0, 1
      when @keyCodes.Y, @keyCodes.NUMPAD_7
        @move rogue, -1, -1
      when @keyCodes.U, @keyCodes.NUMPAD_9
        @move rogue, 1, -1
      when @keyCodes.B, @keyCodes.NUMPAD_1
        @move rogue, -1, 1
      when @keyCodes.N, @keyCodes.NUMPAD_3
        @move rogue, 1, 1

  addRogue: (socket) =>
    loop
      x = Math.floor (@screenWidth * Math.random())
      y = Math.floor (@screenHeight * Math.random())
      break if @screen[x][y] is '.'
    newRogue = { x, y, socket }
    @rogues.push newRogue
    @setChar '@', x, y
    return newRogue

  setChar: (char, x, y) =>
    @screen[x][y] = char
    for rogue in @rogues
      rogue.socket.emit 'display', { char, x, y }

  isValid: (x, y) =>
    return x in [0..(@screenWidth-1)] and y in [0..(@screenHeight-1)]

  move: (rogue, dx, dy) =>
    oldPos = { x: rogue.x, y: rogue.y }
    newPos = { x: oldPos.x + dx, y: oldPos.y + dy }
    return unless @isValid newPos.x, newPos.y
    rogue.x = newPos.x
    rogue.y = newPos.y
    @setChar '.', oldPos.x, oldPos.y
    @setChar '@', rogue.x, rogue.y
