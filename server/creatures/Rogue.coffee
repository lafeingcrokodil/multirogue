EventEmitter = require('events').EventEmitter

Level = require './Level'

class Rogue extends EventEmitter
  module.exports = Rogue

  type: 'ROGUE'
  stats:
    level: 1
    experience: 0
    maxHitPoints: 20
    hitPoints: 20
    maxStrength: 1
    strength: 1
    armourClass: 1
    gold: 0
  inventory: []

  constructor: (@socket, @dungeonLevel) ->

  getStats: =>
    return @stats
    
  changeExperience: (dExp) =>
    @stats.experience += dExp
    @stats.level = Level.update @stats.level, @stats.experience
    @socket.emit 'stats', @getStats()

  attack: (monster) =>
    if Dice.roll '1d100' <= @getHitChance monster
      damage = @getDamage()
      @emit 'hit', { monster, damage }
      monster.dealDamage damage
    else
      @emit 'miss', { monster }
      return false # monster wasn't defeated

  getHitChance: (monster) =>
    levelBonus = @stats.level
    armourBonus = 10 - monster.armourClass
    strengthBonus = switch
      when @stats.strength < 8 then @stats.strength - 7
      when @stats.strength <= 16 then 0
      when @stats.strength <= 20 then 1
      when @stats.strength <= 30 then 2
      when @stats.strength >= 31 then 3
    weaponBonus = @weapon.accuracyBonus
    # TODO: add +4 bonus if the monster is asleep or captive
    hitChance = 5 * (1 + levelBonus + armourBonus + strengthBonus + weaponBonus)

  getDamage: =>
    strengthBonus = switch
      when @stats.strength < 8 then @stats.strength - 7
      when @stats.strength < 16 then 0
      when @stats.strength < 18 then 1
      when @stats.strength < 19 then 2
      when @stats.strength < 21 then 3
      when @stats.strength < 22 then 4
      when @stats.strength < 31 then 5
      when @stats.strength >= 31 then 6
    return Dice.roll(@weapon.damageDice) + @weapon.damageBonus + strengthBonus

  dealDamage: (amount) =>
    @stats.hitPoints = Math.max 0, @stat.hitPoints - amount
    @socket.emit 'stats', @getStats()
    return @stats.hitPoints <= 0
