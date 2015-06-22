Monster = require '../Monster'

class FlyTrap extends Monster
  module.exports = FlyTrap

  type: 'FLYTRAP'
  name: 'venus flytrap'
  level: 8
  damageDice: '0d0' # TODO: should increase with time
  armourClass: 7
  baseExp: 80
  expBonus: 2/3
