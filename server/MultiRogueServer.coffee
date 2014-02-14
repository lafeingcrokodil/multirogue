fs   = require 'fs'
path = require 'path'

Map  = require './Map'

class MultiRogueServer
  module.exports = MultiRogueServer

  rogues: []
  monsters: []

  movedCount: 0
  turnCount: 0

  constructor: ->
    # load key code mapping
    keyCodeStr = fs.readFileSync path.join('server', 'keyCodes.json'), 'utf8'
    @keyCodes = JSON.parse keyCodeStr

    @map = new Map

  broadcast: (event, data) =>
    for rogue in @rogues
      rogue.socket.emit event, data

  handleConnection: (socket) =>
    rogue = @addRogue socket
    socket.emit 'map', { map: @map.getSnapshot(), rows: @map.rows, cols: @map.cols }
    socket.on 'key', @handleKeyEvent(rogue)
    socket.on 'disconnect', @removeRogue(rogue)

  handleKeyEvent: (rogue) => (code) =>
    switch code
      when @keyCodes.H, @keyCodes.NUMPAD_4
        @move rogue, 0, -1
      when @keyCodes.L, @keyCodes.NUMPAD_6
        @move rogue, 0, 1
      when @keyCodes.K, @keyCodes.NUMPAD_8
        @move rogue, -1, 0
      when @keyCodes.J, @keyCodes.NUMPAD_2
        @move rogue, 1, 0
      when @keyCodes.Y, @keyCodes.NUMPAD_7
        @move rogue, -1, -1
      when @keyCodes.U, @keyCodes.NUMPAD_9
        @move rogue, -1, 1
      when @keyCodes.B, @keyCodes.NUMPAD_1
        @move rogue, 1, -1
      when @keyCodes.N, @keyCodes.NUMPAD_3
        @move rogue, 1, 1
      when @keyCodes.PERIOD, @keyCodes.NUMPAD_5
        if rogue.canMove
          rogue.canMove = false
          do @handleEndMove

  addRogue: (socket) =>
    console.log "[#{socket.handshake.address.address}] Rogue joined."
    newRogue = { socket, type: 'ROGUE', canMove: true }
    @occupy newRogue
    @rogues.push newRogue
    return newRogue

  removeRogue: (rogue) => () =>
    console.log "[#{rogue.socket.handshake.address.address}] Rogue left."
    index = @rogues.indexOf rogue
    @rogues.splice index, 1
    @unoccupy rogue.row, rogue.col

  spawnMonster: (type) =>
    newMonster = { type, canMove: true }
    @occupy newMonster
    @monsters.push newMonster

  move: (creature, dRow, dCol) =>
    return unless creature.canMove
    oldPos = { row: creature.row, col: creature.col }
    newPos = { row: oldPos.row + dRow, col: oldPos.col + dCol }
    return unless @map.isValid newPos.row, newPos.col
    creature.canMove = false if creature.type is 'ROGUE'
    @unoccupy oldPos.row, oldPos.col
    @occupy creature, newPos.row, newPos.col
    do @handleEndMove if creature.type is 'ROGUE'

  moveMonsters: =>
    for monster, i in @monsters
      if @rogues.length > 0
        target = @rogues[i % @rogues.length]
        dRow = @compare target.row, monster.row
        dCol = @compare target.col, monster.col
        @move monster, dRow, dCol

  compare: (a, b) =>
    if a < b then -1 else if a > b then 1 else 0

  occupy: (occupant, row, col) =>
    { char, row, col } = @map.occupy occupant, row, col
    @broadcast 'display', { char, row, col }

  unoccupy: (row, col) =>
    { char } = @map.unoccupy row, col
    @broadcast 'display', { char, row, col }

  handleEndMove: =>
    if (++@movedCount) is @rogues.length
      do @handleNewTurn
      @movedCount = 0
      for rogue in @rogues
        rogue.canMove = true

  handleNewTurn: =>
    @turnCount++
    if @turnCount % 10 is 0
      @spawnMonster 'EMU'
    do @moveMonsters
