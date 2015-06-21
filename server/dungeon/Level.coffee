_    = require 'lodash'
fs   = require 'fs'
path = require 'path'

symbols = require './symbols'

monsters =
  Emu: require '../creatures/monsters/Emu'

class Level
  module.exports = Level

  constructor: (filePath) ->
    @tiles = @loadFromFile filePath
    @name = path.basename filePath, '.txt'

    # calculate level size
    @rows = @tiles.length
    @cols = @tiles[0].length

    @rogues   = [] # living rogues
    @monsters = [] # living monsters

    for i in [1..4]
      @spawnMonster()

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
    creature.dungeonLevel = @
    @occupy creature
    list = if creature.type is 'ROGUE' then @rogues else @monsters
    list.push creature
    if creature.type is 'ROGUE'
      creature.socket.emit 'level',
        name: @name
        map: @getMap()
        rogues: @rogues.map (rogue) -> _.pick rogue, 'row', 'col', 'name'
      creature.socket.emit 'stats', creature.getStats()

  removeCreature: (creature) =>
    @unoccupy creature.row, creature.col
    list = if creature.type is 'ROGUE' then @rogues else @monsters
    _.remove list, creature

  spawnMonster: =>
    @addCreature new monsters.Emu # TODO: pick random monster based on dungeon level

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
    displayData = { char: @symbolAt(row, col), row, col, name: occupant.name }
    @broadcast 'display', displayData

  unoccupy: (row, col) =>
    @tiles[row][col].occupant = null
    @broadcast 'display', { char: @symbolAt(row, col), row, col }

  getRandomSpawnPos: =>
    loop # trial and error
      row = Math.floor (@rows * Math.random())
      col = Math.floor (@cols * Math.random())
      break if @isValidSpawnPos(row, col) and not @getOccupant(row, col)
    return { row, col }

  isValid: (row, col) =>
    inBounds = 0 <= row < @rows and 0 <= col < @cols
    terrainOK = @tiles[row][col].terrain in [
      symbols.GROUND,
      symbols.DOOR,
      symbols.PASSAGE,
      symbols.STAIRCASE,
      symbols.TRAP
    ]
    return inBounds and terrainOK

  isValidSpawnPos: (row, col) =>
    @isValid(row, col) and @tiles[row][col].terrain in [
      symbols.GROUND,
      symbols.STAIRCASE
    ]

  isStaircase: (row, col) =>
    @tiles[row][col].terrain is symbols.STAIRCASE

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
