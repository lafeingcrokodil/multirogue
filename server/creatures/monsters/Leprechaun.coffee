Monster = require '../Monster'

class Leprechaun extends Monster
  module.exports = Leprechaun

  type: 'LEPRECHAUN'
  name: 'leprechaun'
  level: 3
  damageDice: '1d1'
  armourClass: 2
  baseExp: 10
  expBonus: 1/6
