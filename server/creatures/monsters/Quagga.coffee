Monster = require '../Monster'

class Quagga extends Monster
  module.exports = Quagga

  type: 'QUAGGA'
  name: 'quagga'
  level: 3
  damageDice: '1d5+1d5'
  armourClass: 7
  baseExp: 15
  expBonus: 1/6
