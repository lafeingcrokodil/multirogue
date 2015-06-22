Monster = require '../Monster'

class Nymph extends Monster
  module.exports = Nymph

  type: 'NYMPH'
  name: 'nymph'
  level: 3
  damageDice: '0d0'
  armourClass: 1
  baseExp: 37
  expBonus: 1/6
