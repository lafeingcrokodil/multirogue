Level = require './Level'

class Dungeon
  module.exports = Dungeon

  levels: []

  constructor: ->
    for i in [1..21]
      @levels.push new Level i

  getAdjacentLevel: (level, direction) =>
    levelIndex = parseInt(level.name, 10) - 1
    if direction is 'down'
      return @levels[levelIndex + 1]
    else
      return @levels[levelIndex - 1]
