Monster = require '../Monster'

class Vampire extends Monster
  module.exports = Vampire

  type: 'VAMPIRE'
  name: 'vampire'
  level: 8
  damageDice: '1d10'
  armourClass: 9
  baseExp: 350
  expBonus: 2/3
