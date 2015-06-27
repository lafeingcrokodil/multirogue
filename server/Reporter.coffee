debug = require 'debug'

class Reporter
  module.exports = Reporter

  constructor: (@io) ->
    @messages = {} # TODO: delete messages upon disconnect

  report: (event, data) =>
    switch event
      when 'join'
        { name, ip } = data
        @messages[name] = []
        debug('server') "[#{ip}] #{name} joined"
        @broadcast 'notify', "#{name} joined"
      when 'disconnect'
        { name, ip } = data
        delete @messages[name]
        debug('server') "[#{ip}] #{name} left"
        @broadcast 'notify', "#{name} left"
      when 'hit'
        { attacker, victim, hitPoints, damage } = data
        hitPointStr = "#{data.hitPoints} -> #{data.hitPoints - data.damage}"
        debug('game') "#{attacker.name} hit #{victim.name} (#{hitPointStr})"
        if attacker.type is 'ROGUE'
          @messages[attacker.name].push "You hit the #{victim.name}"
        if victim.type is 'ROGUE'
          @messages[victim.name].push "The #{attacker.name} hit you"
      when 'miss'
        { attacker, victim } = data
        debug('game') "#{attacker.name} missed #{victim.name}"
        if attacker.type is 'ROGUE'
          @messages[attacker.name].push "You missed the #{victim.name}"
        if victim.type is 'ROGUE'
          @messages[victim.name].push "The #{attacker.name} missed you"
      when 'defeat'
        { attacker, victim } = data
        debug('game') "#{attacker.name} defeated #{victim.name}"
        @broadcast 'notify', "#{attacker.name} defeated #{victim.name}"
        if attacker.type is 'ROGUE'
          @messages[attacker.name].push "You defeated the #{victim.name}"
        if victim.type is 'ROGUE'
          @messages[victim.name].push "You were defeated by the #{attacker.name}"
      when 'levelup'
        { rogue, level } = data
        debug('game') "#{rogue.name} reached level #{level}"
        @broadcast 'notify', "#{rogue.name} levelled up"
        @messages[rogue.name].push "Welcome to level #{level}"
      when 'end'
        creature = data
        if creature.type is 'ROGUE' and @messages[creature.name]?.length
          messages = @messages[creature.name]
          @messages[creature.name] = []
          creature.socket.emit 'narration', messages

  broadcast: (event, data) =>
    @io.emit event, data
