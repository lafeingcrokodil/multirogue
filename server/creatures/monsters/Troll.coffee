Monster = require '../Monster'

class Troll extends Monster
  module.exports = Troll

  type: 'TROLL'
  name: 'troll'
  level: 6
  damageDice: '1d8+1d8+2d6'
  armourClass: 6
  baseExp: 120
  expBonus: 1/6
