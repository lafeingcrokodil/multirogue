Monster = require '../Monster'

class Medusa extends Monster
  module.exports = Medusa

  type: 'MEDUSA'
  name: 'medusa'
  level: 8
  damageDice: '3d4+3d4+2d5'
  armourClass: 8
  baseExp: 200
  expBonus: 2/3
