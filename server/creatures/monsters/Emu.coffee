Monster = require '../Monster'

class Emu extends Monster
  module.exports = Emu

  type: 'EMU'
  numHitDice: 1
  damageDice: '1d2'
  armourClass: 3
  baseExp: 2
  expBonus: 1/8
