Monster = require '../Monster'

class IceMonster extends Monster
  module.exports = IceMonster

  type: 'ICE_MONSTER'
  name: 'ice monster'
  level: 1
  damageDice: '0d0'
  armourClass: 1
  baseExp: 5
  expBonus: 1/8
