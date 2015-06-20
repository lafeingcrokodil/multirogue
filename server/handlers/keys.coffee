
keyCodes = require '../keyCodes'

module.exports = (server) -> (rogue) -> (code) ->
  switch keyCodes[code]
    when 'H', 'NUMPAD_4'
      server.move rogue, 0, -1  # move left
    when 'L', 'NUMPAD_6'
      server.move rogue, 0, 1   # move right
    when 'K', 'NUMPAD_8'
      server.move rogue, -1, 0  # move up
    when 'J', 'NUMPAD_2'
      server.move rogue, 1, 0   # move down
    when 'Y', 'NUMPAD_7'
      server.move rogue, -1, -1 # move north-west
    when 'U', 'NUMPAD_9'
      server.move rogue, -1, 1  # move north-east
    when 'B', 'NUMPAD_1'
      server.move rogue, 1, -1  # move south-west
    when 'N', 'NUMPAD_3'
      server.move rogue, 1, 1   # move south-east
    when 'PERIOD', 'NUMPAD_5'
      server.move rogue, 0, 0   # rest (no movement)
