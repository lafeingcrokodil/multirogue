Monster = require '../Monster'

class Zombie extends Monster
  module.exports = Zombie

  type: 'ZOMBIE'
  name: 'zombie'
  level: 2
  damageDice: '1d8'
  armourClass: 2
  baseExp: 6
  expBonus: 1/6
