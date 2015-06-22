Monster = require '../Monster'

class Snake extends Monster
  module.exports = Snake

  type: 'SNAKE'
  name: 'snake'
  level: 1
  damageDice: '1d3'
  armourClass: 5
  baseExp: 2
  expBonus: 1/8
