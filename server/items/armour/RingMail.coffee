class RingMail
  module.exports = RingMail

  type: 'ARMOUR'
  name: 'ring mail'
  baseArmourClass: 3

  constructor: (@defenceBonus = 0) ->

  getArmourClass: =>
    @baseArmourClass + @defenceBonus
