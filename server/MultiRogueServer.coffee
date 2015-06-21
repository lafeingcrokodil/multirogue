_     = require 'lodash'
debug = require 'debug'

Dungeon = require './dungeon/Dungeon'
Rogue   = require './creatures/Rogue'

class MultiRogueServer
  module.exports = MultiRogueServer

  players: [] # all players connected to the current game

  constructor: (@io) ->
    @dungeon = new Dungeon
    @io.sockets.on 'connection', @handleConnection

  handleConnection: (socket) =>
    debug('server') "[#{@getIP socket}] Rogue joined."
    @players.push rogue

    rogue = new Rogue socket
    @dungeon.levels[0].addCreature rogue

    socket.on 'move', ({ dRow, dCol }) => @move rogue, dRow, dCol
    socket.on 'staircase', ({ direction }) => @useStaircase rogue, direction
    socket.on 'disconnect', @removePlayer(rogue)
    socket.on 'error', (err) -> debug('error') err.stack

    rogue.on 'hit', ({ monster, hitPoints, damage }) =>
      debug('game') "Rogue hit #{monster.type.toLowerCase()} (#{hitPoints} -> #{hitPoints - damage})!"
    rogue.on 'miss', ({ monster }) =>
      debug('game') "Rogue missed #{monster.type.toLowerCase()}!"
    rogue.on 'defeat', @handleDefeat
    rogue.on 'deceased', => @handleDefeat(rogue)

  removePlayer: (rogue) => =>
    debug('server') "[#{@getIP rogue.socket}] Rogue left."
    _.remove @players, rogue
    rogue.dungeonLevel.removeCreature rogue

  handleDefeat: (creature, murderer) =>
    debug('game') "#{murderer.type} defeated #{creature.type}!"
    if murderer.type is 'ROGUE'
      murderer.changeExperience creature.getExperience()
    creature.dungeonLevel.removeCreature creature

  move: (creature, dRow, dCol) =>
    if dRow or dCol
      oldPos = { row: creature.row, col: creature.col }
      newPos = { row: oldPos.row + dRow, col: oldPos.col + dCol }
      return unless creature.dungeonLevel.isValid newPos.row, newPos.col
      occupant = creature.dungeonLevel.getOccupant newPos.row, newPos.col
      return if occupant and @isAlly creature, occupant
      victory = creature.attack occupant if occupant
      if victory
        @handleDefeat occupant, creature
      if victory or not occupant
        creature.dungeonLevel.unoccupy oldPos.row, oldPos.col
        creature.dungeonLevel.occupy creature, newPos.row, newPos.col

  isAlly: (creature, other) =>
    bothRogues = creature.type is 'ROGUE' and other.type is 'ROGUE'
    bothMonsters = creature.type isnt 'ROGUE' and other.type isnt 'ROGUE'
    return bothRogues or bothMonsters

  useStaircase: (rogue, direction) =>
    if rogue.dungeonLevel.isStaircase rogue.row, rogue.col
      rogue.dungeonLevel.removeCreature rogue
      level = @dungeon.getAdjacentLevel rogue.dungeonLevel, direction
      level.addCreature rogue

  broadcast: (event, data) =>
    @io.emit event, data

  getIP: (socket) -> socket.client.conn.remoteAddress
