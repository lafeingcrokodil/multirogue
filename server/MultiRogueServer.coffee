_ = require 'lodash'

Map             = require './Map'
KeyEventHandler = require './KeyEventHandler'

class MultiRogueServer
  module.exports = MultiRogueServer

  players  : [] # all players connected to the current game
  rogues   : [] # living players
  monsters : [] # living monsters

  movedCount: 0
  turnCount: 0

  constructor: (@io) ->
    @map = new Map
    @keyEventHandler = new KeyEventHandler @
    @io.sockets.on 'connection', @handleConnection

  broadcast: (event, data) =>
    @io.emit event, data

  getIP: (socket) =>
    socket.client.conn.remoteAddress

  handleConnection: (socket) =>
    rogue = @addRogue socket
    socket.emit 'map', { map: @map.getSnapshot(), rows: @map.rows, cols: @map.cols }
    socket.emit 'stats', { hp: rogue.hp }
    socket.on 'key', @keyEventHandler.handle(rogue)
    socket.on 'disconnect', @removeRogue(rogue)

  addRogue: (socket) =>
    console.log "[#{@getIP socket}] Rogue joined."
    newRogue = { socket, type: 'ROGUE', canMove: true, hp: 20 }
    @occupy newRogue
    @players.push newRogue
    @rogues.push newRogue
    return newRogue

  removeRogue: (rogue) => () =>
    console.log "[#{@getIP rogue.socket}] Rogue left."
    for list in [@rogues, @players]
      _.remove list, rogue
    @unoccupy rogue.row, rogue.col
    if @rogues.every((rogue) -> not rogue.canMove)
      do @handleNewTurn

  handleDefeat: (creature) =>
    if creature.type is 'ROGUE'
      creature.canMove = false
      list = @rogues
    else
      list = @monsters
    _.remove list, creature
    @unoccupy creature.row, creature.col

  spawnMonster: (type) =>
    newMonster = { type, canMove: true, hp: 5 }
    @occupy newMonster
    @monsters.push newMonster

  move: (creature, dRow, dCol) =>
    return unless creature.canMove
    if dRow or dCol
      oldPos = { row: creature.row, col: creature.col }
      newPos = { row: oldPos.row + dRow, col: oldPos.col + dCol }
      return unless @map.isValid newPos.row, newPos.col
      occupant = @map.getOccupant newPos.row, newPos.col
      return if occupant and @isAlly creature, occupant
      victory = @attack creature, occupant if occupant
      if victory
        console.log "#{occupant.type} defeated by #{creature.type}"
        @handleDefeat occupant
      if victory or not occupant
        @unoccupy oldPos.row, oldPos.col
        @occupy creature, newPos.row, newPos.col
    if creature.type is 'ROGUE'
      creature.canMove = false
      if (++@movedCount) is @rogues.length
        do @handleNewTurn

  moveMonsters: =>
    for monster, i in @monsters
      if @rogues.length > 0
        target = @rogues[i % @rogues.length]
        dRow = @compare target.row, monster.row
        dCol = @compare target.col, monster.col
        @move monster, dRow, dCol

  attack: (assailant, victim) =>
    victim.hp--
    if victim.type is 'ROGUE'
      victim.socket.emit 'stats', { hp: victim.hp }
    return victim.hp <= 0

  isAlly: (creature, other) =>
    bothRogues = creature.type is 'ROGUE' and other.type is 'ROGUE'
    bothMonsters = creature.type isnt 'ROGUE' and other.type isnt 'ROGUE'
    return bothRogues or bothMonsters

  compare: (a, b) =>
    if a < b then -1 else if a > b then 1 else 0

  occupy: (occupant, row, col) =>
    { char, row, col } = @map.occupy occupant, row, col
    @broadcast 'display', { char, row, col }

  unoccupy: (row, col) =>
    { char } = @map.unoccupy row, col
    @broadcast 'display', { char, row, col }

  handleNewTurn: =>
    @turnCount++
    if @turnCount % 10 is 0
      @spawnMonster 'EMU'
    do @moveMonsters
    @movedCount = 0
    for rogue in @rogues
      rogue.canMove = true
