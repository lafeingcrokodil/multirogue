Monster = require '../Monster'

class Rattlesnake extends Monster
  module.exports = Rattlesnake

  type: 'RATTLESNAKE'
  name: 'rattlesnake'
  level: 2
  damageDice: '1d6'
  armourClass: 7
  baseExp: 9
  expBonus: 1/6
