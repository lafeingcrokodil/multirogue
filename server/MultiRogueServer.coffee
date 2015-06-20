_ = require 'lodash'

Dungeon = require './dungeon/Dungeon'
Rogue   = require './creatures/Rogue'

monsters =
  Emu: require './creatures/monsters/Emu'

class MultiRogueServer
  module.exports = MultiRogueServer

  players  : [] # all players connected to the current game
  rogues   : [] # living players
  monsters : [] # living monsters

  constructor: (@io) ->
    @dungeon = new Dungeon
    @io.sockets.on 'connection', @handleConnection

  handleConnection: (socket) =>
    console.log "[#{@getIP socket}] Rogue joined."
    rogue = new Rogue socket, @dungeon.levels[0]
    @occupy rogue
    @players.push rogue
    @rogues.push rogue

    socket.emit 'map', rogue.dungeonLevel.getMap()
    socket.emit 'stats', rogue.getStats()

    rogue.on 'move', ({ dRow, dCol }) => @move rogue, dRow, dCol
    rogue.on 'hit', ({ monster }) => console.log "Rogue hit #{monster.type.toLowerCase()}!"
    rogue.on 'miss', ({ monster }) => console.log "Rogue missed #{monster.type.toLowerCase()}!"
    rogue.on 'defeat', @handleDefeat
    rogue.on 'deceased', => @handleDefeat(rogue)
    rogue.on 'disconnect', @removePlayer(rogue)

  removePlayer: (rogue) => =>
    console.log "[#{@getIP rogue.socket}] Rogue left."
    for list in [@rogues, @players]
      _.remove list, rogue
    @unoccupy rogue, rogue.row, rogue.col

  handleDefeat: (creature) =>
    list = if creature.type is 'ROGUE' then @rogues else @monsters
    _.remove list, creature
    @unoccupy creature, creature.row, creature.col

  spawnMonster: =>
    monster = new monsters.Emu # TODO: pick random monster based on dungeon level
    @occupy monster
    @monsters.push monster

  move: (creature, dRow, dCol) =>
    if dRow or dCol
      oldPos = { row: creature.row, col: creature.col }
      newPos = { row: oldPos.row + dRow, col: oldPos.col + dCol }
      return unless creature.dungeonLevel.isValid newPos.row, newPos.col
      occupant = creature.dungeonLevel.getOccupant newPos.row, newPos.col
      return if occupant and @isAlly creature, occupant
      victory = creature.attack occupant if occupant
      if victory
        console.log "#{creature.type} defeated #{occupant.type}!"
        @handleDefeat occupant
      if victory or not occupant
        @unoccupy occupant, oldPos.row, oldPos.col if occupant
        @occupy creature, newPos.row, newPos.col

  isAlly: (creature, other) =>
    bothRogues = creature.type is 'ROGUE' and other.type is 'ROGUE'
    bothMonsters = creature.type isnt 'ROGUE' and other.type isnt 'ROGUE'
    return bothRogues or bothMonsters

  occupy: (occupant, row, col) =>
    { char, row, col } = occupant.dungeonLevel.occupy occupant, row, col
    @broadcast 'display', { char, row, col }

  unoccupy: (occupant, row, col) =>
    { char } = occupant.dungeonLevel.unoccupy row, col
    @broadcast 'display', { char, row, col }

  broadcast: (event, data) =>
    @io.emit event, data

  getIP: (socket) -> socket.client.conn.remoteAddress
