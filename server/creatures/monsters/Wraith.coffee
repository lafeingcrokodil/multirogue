Monster = require '../Monster'

class Wraith extends Monster
  module.exports = Wraith

  type: 'WRAITH'
  name: 'wraith'
  level: 5
  damageDice: '1d6'
  armourClass: 6
  baseExp: 55
  expBonus: 1/6
