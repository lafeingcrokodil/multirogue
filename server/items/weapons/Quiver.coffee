class Quiver
  module.exports = Quiver

  type: 'WEAPON'
  name: 'arrows'
  damageDice:
    held   : '1d1'
    thrown : '2d3'
  remaining: 25

  constructor: (@accuracyBonus = 0, @damageBonus = 0) ->
