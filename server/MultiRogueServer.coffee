_     = require 'lodash'
debug = require 'debug'

Dice    = require './Dice'
Dungeon = require './dungeon/Dungeon'
Rogue   = require './creatures/Rogue'

class MultiRogueServer
  module.exports = MultiRogueServer

  players: [] # all players connected to the current game

  constructor: (@io) ->
    @dungeon = new Dungeon
    @io.sockets.on 'connection', (socket) =>
      socket.emit 'players', _.pluck(@players, 'name')
      socket.on 'join', @addPlayer(socket)

  addPlayer: (socket) => (name) =>
    debug('server') "[#{@getIP socket}] #{name} joined."

    rogue = new Rogue name, socket
    @players.push rogue
    @dungeon.levels[0].addCreature rogue

    socket.on 'move', ({ dRow, dCol }) => @move rogue, dRow, dCol
    socket.on 'staircase', ({ direction }) => @useStaircase rogue, direction
    socket.on 'disconnect', @removePlayer(rogue)
    socket.on 'error', (err) -> debug('error') err.stack

  removePlayer: (rogue) => =>
    debug('server') "[#{@getIP rogue.socket}] #{rogue.name} left."
    _.remove @players, rogue
    rogue.dungeonLevel.removeCreature rogue

  handleDefeat: (attacker, victim) =>
    @report 'defeat', { attacker, victim }
    if attacker.type is 'ROGUE'
      attacker.changeExperience victim.getExperience()
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
      else if occupant and occupant.type isnt 'ROGUE'
        @meleeAttack occupant, creature

  meleeAttack: (attacker, victim) =>
    hitChance = attacker.getHitChance() - victim.getBlockChance()
    for damageDice in attacker.damageDice.split '+'
      if Dice.roll('1d100') <= hitChance
        damage = attacker.getDamage damageDice
        @report 'hit', { attacker, victim, hitPoints: victim.hitPoints, damage }
        victory = victim.takeDamage damage
        if victory
          @handleDefeat attacker, victim
          return true # victim was defeated
      else
        @report 'miss', { attacker, victim }
    return false # victim wasn't defeated

  useStaircase: (rogue, direction) =>
    if rogue.dungeonLevel.isStaircase rogue.row, rogue.col
      rogue.dungeonLevel.removeCreature rogue
      level = @dungeon.getAdjacentLevel rogue.dungeonLevel, direction
      level.addCreature rogue

  report: (event, data) =>
    switch event
      when 'hit'
        { attacker, victim, hitPoints, damage } = data
        hitPointStr = "#{data.hitPoints} -> #{data.hitPoints - data.damage}"
        debug('game') "#{attacker.name} hit #{victim.name} (#{hitPointStr})"
      when 'miss'
        { attacker, victim } = data
        debug('game') "#{attacker.name} missed #{victim.name}"
      when 'defeat'
        { attacker, victim } = data
        debug('game') "#{attacker.name} defeated #{victim.name}"

  broadcast: (event, data) =>
    @io.emit event, data

  getIP: (socket) -> socket.client.conn.remoteAddress
