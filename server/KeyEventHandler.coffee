fs   = require 'fs'
path = require 'path'

class KeyEventHandler
  module.exports = KeyEventHandler

  constructor: (@server) ->
    # load key code mapping
    keyCodeStr = fs.readFileSync path.join('server', 'keyCodes.json'), 'utf8'
    @keyCodes = JSON.parse keyCodeStr

  handle: (rogue) => (code) =>
    switch code
      when @keyCodes.H, @keyCodes.NUMPAD_4
        @server.move rogue, 0, -1  # move left
      when @keyCodes.L, @keyCodes.NUMPAD_6
        @server.move rogue, 0, 1   # move right
      when @keyCodes.K, @keyCodes.NUMPAD_8
        @server.move rogue, -1, 0  # move up
      when @keyCodes.J, @keyCodes.NUMPAD_2
        @server.move rogue, 1, 0   # move down
      when @keyCodes.Y, @keyCodes.NUMPAD_7
        @server.move rogue, -1, -1 # move north-west
      when @keyCodes.U, @keyCodes.NUMPAD_9
        @server.move rogue, -1, 1  # move north-east
      when @keyCodes.B, @keyCodes.NUMPAD_1
        @server.move rogue, 1, -1  # move south-west
      when @keyCodes.N, @keyCodes.NUMPAD_3
        @server.move rogue, 1, 1   # move south-east
      when @keyCodes.PERIOD, @keyCodes.NUMPAD_5
        @server.move rogue, 0, 0   # pass (no movement)
