Monster = require '../Monster'

class Phantom extends Monster
  module.exports = Phantom

  type: 'PHANTOM'
  name: 'phantom'
  level: 8
  damageDice: '4d4'
  armourClass: 7
  baseExp: 120
  expBonus: 2/3
