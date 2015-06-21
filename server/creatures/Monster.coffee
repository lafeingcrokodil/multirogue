Dice = require '../Dice'

class Monster
  module.exports = Monster

  constructor: ->
    hitDice = "#{@numHitDice}d8"
    @hitPoints = @maxHitPoints = Dice.roll hitDice

  getExperience: ->
    @baseExp + @expBonus * @maxHitPoints

  attack: (rogue) ->
    # TODO: minus 5% for each increment on any rings of protection worn by rogue
    hitChance = 20 + 5*@numHitDice + 5*(10 - rogue.getArmourClass())
    if Dice.roll '1d100' <= hitChance
      rogue.takeDamage Dice.roll(@damageDice)

  takeDamage: (amount) ->
    @hitPoints -= amount
    return @hitPoints <= 0
