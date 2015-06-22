Monster = require '../Monster'

class Orc extends Monster
  module.exports = Orc

  type: 'ORC'
  name: 'orc'
  level: 1
  damageDice: '1d8'
  armourClass: 4
  baseExp: 5
  expBonus: 1/8
