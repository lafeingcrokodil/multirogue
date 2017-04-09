Random = require '../Random'

class Monster
  module.exports = Monster

  constructor: ->
    hitDice = "#{@level}d8"
    @hitPoints = @maxHitPoints = Random.roll hitDice

  isAlly: (creature) =>
    creature.type isnt 'ROGUE'

  getHitChance: =>
    return 20 + 5 * @level

  getBlockChance: =>
    # TODO: -4 if asleep or captive
    armourBonus = @armourClass - 10
    return 5 * armourBonus

  getDamage: (damageDice) =>
    Random.roll damageDice

  getExperience: =>
    @baseExp + Math.floor(@expBonus * @maxHitPoints)

  takeDamage: (amount) =>
    @hitPoints -= amount
    return @hitPoints <= 0

  # ASSUMPTION: 'an' should be used iff the creature's name starts with a vowel
  # Override this method if the assumption doesn't hold (e.g. for 'unicorn').
  getIndefiniteArticle: =>
    return if /^[aeiou]/i.test @name then 'an' else 'a'
