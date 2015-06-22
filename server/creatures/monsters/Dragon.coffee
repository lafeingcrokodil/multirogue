Monster = require '../Monster'

class Dragon extends Monster
  module.exports = Dragon

  type: 'DRAGON'
  name: 'dragon'
  level: 10
  damageDice: '1d8+1d8+3d10'
  armourClass: 11
  baseExp: 5000
  expBonus: 10/3
