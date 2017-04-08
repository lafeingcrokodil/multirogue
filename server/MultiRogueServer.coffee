_     = require 'lodash'
debug = require 'debug'

Random   = require './Random'
Dungeon  = require './dungeon/Dungeon'
Rogue    = require './creatures/Rogue'
Reporter = require './Reporter'

class MultiRogueServer
  module.exports = MultiRogueServer

  players: [] # all players connected to the current game

  constructor: (io) ->
    @dungeon = new Dungeon
    @reporter = new Reporter io
    io.sockets.on 'connection', (socket) =>
      socket.on 'error', (err) -> debug('error') err.stack
      socket.emit 'players', _.map(@players, 'name')
      socket.on 'join', @addPlayer(socket)

  addPlayer: (socket) => (name) =>
    @reporter.report 'join', { name, ip: @getIP socket }

    rogue = new Rogue name, socket
    @players.push rogue
    @dungeon.levels[0].addCreature rogue

    socket.on 'move', ({ dRow, dCol }) => @move rogue, dRow, dCol
    socket.on 'staircase', ({ direction }) => @useStaircase rogue, direction
    socket.on 'disconnect', @removePlayer(rogue)

    rogue.on 'levelup', (level) => @reporter.report 'levelup', { rogue, level }

  removePlayer: (rogue) => =>
    @reporter.report 'disconnect', { name: rogue.name, ip: @getIP rogue.socket }
    _.remove @players, rogue
    rogue.dungeonLevel.removeCreature rogue

  handleDefeat: (attacker, victim) =>
    @reporter.report 'defeat', { attacker, victim }
    if attacker.type is 'ROGUE'
      attacker.addExperience victim.getExperience()
    victim.dungeonLevel.removeCreature victim

  move: (creature, dRow, dCol) =>
    if dRow or dCol
      oldPos = { row: creature.row, col: creature.col }
      newPos = { row: oldPos.row + dRow, col: oldPos.col + dCol }
      return unless creature.dungeonLevel.isValid newPos.row, newPos.col
      occupant = creature.dungeonLevel.getOccupant newPos.row, newPos.col
      return if occupant and creature.isAlly occupant
      victory = @meleeAttack creature, occupant if occupant
      if victory or not occupant
        creature.dungeonLevel.unoccupy oldPos.row, oldPos.col
        creature.dungeonLevel.occupy creature, newPos.row, newPos.col
        creature.emit 'move' if creature.type is 'ROGUE'
      else if occupant and occupant.type isnt 'ROGUE'
        @meleeAttack occupant, creature
      @reporter.report 'end', creature
    else # resting
      creature.emit 'move', { resting: true } if creature.type is 'ROGUE'

  meleeAttack: (attacker, victim) =>
    victory = false
    totalDamage = null
    hitChance = attacker.getHitChance() - victim.getBlockChance()
    for damageDice in attacker.damageDice.split '+'
      if Random.roll('1d100') <= hitChance
        damage = attacker.getDamage damageDice
        totalDamage += damage
        victory = victim.takeDamage damage
        break if victory
    if totalDamage?
      @reporter.report 'hit', { attacker, victim, hitPoints: victim.hitPoints, damage: totalDamage }
    else
      @reporter.report 'miss', { attacker, victim }
    if victory
      @handleDefeat attacker, victim
    return victory

  useStaircase: (rogue, direction) =>
    if rogue.dungeonLevel.isStaircase rogue.row, rogue.col
      rogue.dungeonLevel.removeCreature rogue
      level = @dungeon.getAdjacentLevel rogue.dungeonLevel, direction
      level.addCreature rogue

  getIP: (socket) -> socket.client.conn.remoteAddress
