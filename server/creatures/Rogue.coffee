EventEmitter = require('events').EventEmitter

Dice   = require '../Dice'
levels = require './levels'

Food     = require '../items/Food'
RingMail = require '../items/armour/RingMail'
Mace     = require '../items/weapons/Mace'
ShortBow = require '../items/weapons/ShortBow'
Quiver   = require '../items/weapons/Quiver'

class Rogue extends EventEmitter
  module.exports = Rogue

  type: 'ROGUE'
  level: levels[0]
  experience: 0
  maxHitPoints: 12
  hitPoints: 12
  maxStrength: 16
  strength: 16
  gold: 0
  damageDice: '1d4'

  constructor: (@name, @socket) ->
    @inventory =
      a: new Food
      b: new RingMail 1
      c: new Mace 1, 1
      d: new ShortBow 1, 0
      e: new Quiver
    @rings = {}
    @wear @inventory['b']
    @wield @inventory['c']
    @.on 'move', @regenerate()

  isAlly: (creature) =>
    creature.type is 'ROGUE'

  getStats: =>
    level        : @level.number
    experience   : Math.floor @experience
    maxHitPoints : @maxHitPoints
    hitPoints    : @hitPoints
    maxStrength  : @maxStrength
    strength     : @strength
    armourClass  : @getArmourClass()
    gold         : @gold

  getHitChance: =>
    levelBonus = @level.number
    strengthBonus = switch
      when @strength < 8 then @strength - 7
      when @strength <= 16 then 0
      when @strength <= 20 then 1
      when @strength <= 30 then 2
      when @strength >= 31 then 3
    weaponBonus = @weapon?.accuracyBonus or 0
    return 5 * (1 + levelBonus + strengthBonus + weaponBonus)

  getBlockChance: =>
    # TODO: +1 for each increment on rings of protection
    armourBonus = @getArmourClass() - 10
    return 5 * armourBonus

  getDamage: (damageDice) =>
    baseDamageDice = @weapon?.damageDice.held or damageDice
    strengthBonus = switch
      when @strength < 8 then @strength - 7
      when @strength < 16 then 0
      when @strength < 18 then 1
      when @strength < 19 then 2
      when @strength < 21 then 3
      when @strength < 22 then 4
      when @strength < 31 then 5
      when @strength >= 31 then 6
    weaponBonus = @weapon?.damageBonus or 0
    damage = Dice.roll(baseDamageDice) + weaponBonus + strengthBonus
    return Math.max damage, 0

  getArmourClass: =>
    @armour?.getArmourClass() or 0

  takeDamage: (amount) =>
    @hitPoints = Math.max 0, @hitPoints - amount
    @socket.emit 'stats', @getStats()
    return @hitPoints <= 0

  addExperience: (dExp) =>
    @experience += dExp
    currLevelNumber = @level.number
    nextLevel = levels[@level.number]
    while nextLevel and @experience >= nextLevel.minExp
      @level = nextLevel
      @maxHitPoints += Dice.roll '1d10'
      @hitPoints += Dice.roll '1d10'
      nextLevel = levels[@level.number]
    if @level.number > currLevelNumber
      @socket.emit 'notify', "Welcome to level #{@level.number}!"
    @socket.emit 'stats', @getStats()

  wear: (armour) =>
    if armour.type is 'ARMOUR'
      @armour = armour

  wield: (weapon) =>
    if weapon.type is 'WEAPON'
      @weapon = weapon

  regenerate: =>
    count = 0
    return =>
      count++
      if count >= @level.healDelay
        if @hitPoints < @maxHitPoints
          healAmount = Dice.roll @level.healDice
          @hitPoints = Math.min @maxHitPoints, @hitPoints + healAmount
          @socket.emit 'stats', @getStats()
        count = 0
