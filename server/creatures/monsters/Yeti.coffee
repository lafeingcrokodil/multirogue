Monster = require '../Monster'

class Yeti extends Monster
  module.exports = Yeti

  type: 'YETI'
  name: 'yeti'
  level: 4
  damageDice: '1d6+1d6'
  armourClass: 4
  baseExp: 50
  expBonus: 1/6
