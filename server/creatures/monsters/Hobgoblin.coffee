Monster = require '../Monster'

class Hobgoblin extends Monster
  module.exports = Hobgoblin

  type: 'HOBGOBLIN'
  name: 'hobgoblin'
  level: 1
  damageDice: '1d8'
  armourClass: 5
  baseExp: 3
  expBonus: 1/8
