class ShortBow
  module.exports = ShortBow

  type: 'WEAPON'
  name: 'short bow'
  damageDice:
    held   : '1d1'
    thrown : '1d1'

  constructor: (@accuracyBonus = 0, @damageBonus = 0) ->
