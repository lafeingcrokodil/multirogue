Monster = require '../Monster'

class Jabberwock extends Monster
  module.exports = Jabberwock

  type: 'JABBERWOCK'
  name: 'jabberwock'
  level: 15
  damageDice: '2d12+2d4'
  armourClass: 4
  baseExp: 3000
  expBonus: 10/3
