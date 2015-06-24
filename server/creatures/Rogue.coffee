EventEmitter = require('events').EventEmitter

Dice  = require '../Dice'
Level = require './Level'

Food     = require '../items/Food'
RingMail = require '../items/armour/RingMail'
Mace     = require '../items/weapons/Mace'
ShortBow = require '../items/weapons/ShortBow'
Quiver   = require '../items/weapons/Quiver'

class Rogue extends EventEmitter
  module.exports = Rogue

  type: 'ROGUE'
  level: 1
  experience: 0
  maxHitPoints: 20
  hitPoints: 20
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
    level        : @level
    experience   : Math.floor @experience
    maxHitPoints : @maxHitPoints
    hitPoints    : @hitPoints
    maxStrength  : @maxStrength
    strength     : @strength
    armourClass  : @getArmourClass()
    gold         : @gold

  getHitChance: =>
    levelBonus = @level
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

  changeExperience: (dExp) =>
    @experience += dExp
    @level = Level.update @level, @experience
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
      { healDice, healDelay } = Level.get @level
      if count >= healDelay
        if @hitPoints < @maxHitPoints
          healAmount = Dice.roll healDice
          @hitPoints = Math.min @maxHitPoints, @hitPoints + healAmount
          @socket.emit 'stats', @getStats()
        count = 0
