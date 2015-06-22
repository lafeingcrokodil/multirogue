Monster = require '../Monster'

class Centaur extends Monster
  module.exports = Centaur

  type: 'CENTAUR'
  name: 'centaur'
  level: 4
  damageDice: '1d2+1d5+1d5'
  armourClass: 6
  baseExp: 17
  expBonus: 1/6
