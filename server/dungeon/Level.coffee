_    = require 'lodash'
fs   = require 'fs'
path = require 'path'

symbols = require './symbols'

monsters =
  Emu: require '../creatures/monsters/Emu'

class Level
  module.exports = Level

  rogues   : [] # living rogues
  monsters : [] # living monsters

  constructor: (filePath) ->
    @tiles = @loadFromFile filePath
    @name = path.basename filePath, '.txt'

    # calculate level size
    @rows = @tiles.length
    @cols = @tiles[0].length

  loadFromFile: (filePath) ->
    levelFile = fs.readFileSync filePath, 'utf8'

    tiles = []
    for row in levelFile.split /[\r\n]+/
      tiles.push row.split('').map (char) -> { terrain: char }

    return tiles

  broadcast: (event, data) =>
    for rogue in @rogues
      rogue.socket.emit event, data

  addCreature: (creature) =>
    @occupy creature
    list = if creature.type is 'ROGUE' then @rogues else @monsters
    list.push creature

  removeCreature: (creature) =>
    @unoccupy creature.row, creature.col
    list = if creature.type is 'ROGUE' then @rogues else @monsters
    _.remove list, creature

  spawnMonster: =>
    monster = new monsters.Emu # TODO: pick random monster based on dungeon level
    @occupy monster
    @monsters.push monster

  ###
  Places the specified occupant at the specified position.
  If no position is provided, a valid position is chosen randomly.
  ###
  occupy: (occupant, row, col) =>
    unless row? and col?
      { row, col } = @getRandomSpawnPos()
    @tiles[row][col].occupant = occupant
    occupant.row = row
    occupant.col = col
    @broadcast 'display', { char: @symbolAt(row, col), row, col }

  unoccupy: (row, col) =>
    @tiles[row][col].occupant = null
    @broadcast 'display', { char: @symbolAt(row, col), row, col }

  getRandomSpawnPos: =>
    loop # trial and error
      row = Math.floor (@rows * Math.random())
      col = Math.floor (@cols * Math.random())
      break if @isValid(row, col) and not @getOccupant(row, col)
    return { row, col }

  isValid: (row, col) =>
    inBounds = 0 <= row < @rows and 0 <= col < @cols
    terrainOK = @tiles[row][col].terrain in [
      symbols.GROUND,
      symbols.DOOR,
      symbols.PASSAGE,
      symbols.TRAP
    ]
    return inBounds and terrainOK

  getOccupant: (row, col) =>
    return @tiles[row][col].occupant

  ###
  Returns a two-dimensional array containing the symbols
  currently visible on the level. For unoccupied tiles, the
  visible symbol is the terrain symbol and for occupied tiles
  it is the occupant's symbol (e.g. 'E', if it's an emu).
  ###
  getMap: =>
    map = []
    for row in @tiles
      map.push row.map (tile) => @getSymbol tile
    return map

  ###
  Returns the symbol that is visible at the specified position.
  ###
  symbolAt: (row, col) =>
    @getSymbol @tiles[row][col]

  ###
  Returns the symbol that is visible on the specified tile.
  ###
  getSymbol: (tile) =>
    if tile.occupant then symbols[tile.occupant.type] else tile.terrain
