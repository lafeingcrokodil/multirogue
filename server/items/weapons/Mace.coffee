class Mace
  module.exports = Mace

  type: 'WEAPON'
  name: 'mace'
  damageDice:
    held   : '2d4'
    thrown : '1d3'

  constructor: (@accuracyBonus = 0, @damageBonus = 0) ->
