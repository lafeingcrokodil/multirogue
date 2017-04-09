fs   = require 'fs'
path = require 'path'

class Tombstone
  module.exports = Tombstone

  constructor: (deceased, status, data = {}) ->
    switch status
      when 'killed'
        { attacker } = data
        culprit = attacker.name
        if attacker.type is 'ROGUE'
          action = 'killed by'
        else
          action = "killed by #{attacker.getIndefiniteArticle()}"
      else
        action = 'died of'
        culprit = data.cause or 'mysterious causes'
    contents =
      name: deceased.name
      gold: "#{deceased.gold} Au"
      action: action
      culprit: culprit
      year: new Date().getFullYear()
    tombstonePath = path.join __dirname, 'tombstone.txt'
    tombstoneStr = fs.readFileSync tombstonePath, 'utf8'
    for key, value of contents
      regex = ///<#{key}\s+>///
      placeholder = tombstoneStr.match(regex)[0]
      tombstoneStr = tombstoneStr.replace regex, pad("#{value}", placeholder.length)
    console.log tombstoneStr
    @map = []
    for row in tombstoneStr.split '\n'
      @map.push row.split ''

  toLevel: =>
    name: 'tombstone'
    map: @map
    rogues: []

pad = (text, length) ->
  missing = Math.max length - text.length, 0
  missingBefore = Math.floor missing / 2
  missingAfter = Math.ceil missing / 2
  before = (' ' for i in [0..missingBefore - 1]).join ''
  after = (' ' for i in [0..missingAfter - 1]).join ''
  return "#{before}#{text}#{after}"
