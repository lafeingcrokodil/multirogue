Monster = require '../Monster'

class Bat extends Monster
  module.exports = Bat

  type: 'BAT'
  name: 'bat'
  level: 1
  damageDice: '1d2'
  armourClass: 7
  baseExp: 1
  expBonus: 1/8
