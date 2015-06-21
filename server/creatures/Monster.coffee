Dice = require '../Dice'

class Monster
  module.exports = Monster

  constructor: ->
    hitDice = "#{@numHitDice}d8"
    @hitPoints = @maxHitPoints = Dice.roll hitDice

  isAlly: (creature) =>
    creature.type isnt 'ROGUE'

  getHitChance: =>
    return 20 + 5 * @numHitDice

  getBlockChance: =>
    # TODO: -4 if asleep or captive
    armourBonus = @armourClass - 10
    return 5 * armourBonus

  getDamage: =>
    Dice.roll @damageDice

  getExperience: =>
    @baseExp + @expBonus * @maxHitPoints

  takeDamage: (amount) =>
    @hitPoints -= amount
    return @hitPoints <= 0
