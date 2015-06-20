fs   = require 'fs'
path = require 'path'

Level = require './Level'

class Dungeon
  module.exports = Dungeon

  levels: []

  constructor: ->
    levelsFolder = path.join 'server', 'dungeon', 'levels'
    fs.readdirSync(levelsFolder).map (filename) =>
      @levels.push new Level(path.join(levelsFolder, filename))
