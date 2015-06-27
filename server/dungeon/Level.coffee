_ = require 'lodash'

symbols   = require './symbols'
monsters  = require '../creatures/monsters'
Generator = require './Generator'

class Level
  module.exports = Level

  constructor: (index) ->
    @tiles = Generator.generateLevel().map (row, i) ->
      row.map (char, j) -> { row: i, col: j, terrain: char, explored: [] }
    @name = "#{index}"

    # calculate level size
    @rows = @tiles.length
    @cols = @tiles[0].length

    @rogues   = [] # living rogues
    @monsters = [] # living monsters
    @moveListeners = {}

    for name, Monster of monsters
      @addCreature new Monster

  broadcast: (event, data) =>
    for rogue in @rogues
      rogue.socket.emit event, data

  addCreature: (creature) =>
    creature.dungeonLevel = @
    @occupy creature
    list = if creature.type is 'ROGUE' then @rogues else @monsters
    list.push creature
    if creature.type is 'ROGUE'
      @explore creature
      @moveListeners[creature.name] = (data) =>
        exploredTiles = @explore creature unless data?.resting
        creature.socket.emit 'display', exploredTiles
      creature.on 'move', @moveListeners[creature.name]
      creature.socket.emit 'level',
        name: @name
        map: @getMap creature
        rogues: @rogues.map (rogue) -> _.pick rogue, 'row', 'col', 'name'
      creature.socket.emit 'stats', creature.getStats()

  removeCreature: (creature) =>
    if creature.type is 'ROGUE'
      creature.removeListener 'move', @moveListeners[creature.name]
    @unoccupy creature.row, creature.col
    list = if creature.type is 'ROGUE' then @rogues else @monsters
    _.remove list, creature

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
    @broadcast 'display', @getDisplayData @tiles[row][col]

  unoccupy: (row, col) =>
    @tiles[row][col].occupant = null
    @broadcast 'display', @getDisplayData @tiles[row][col]

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

  explore: (rogue, tile) =>
    exploredTiles = []
    tile or= @tiles[rogue.row][rogue.col]
    tile.explored.push rogue.name
    exploredTiles.push @getDisplayData(tile)
    for i in [-1..1]
      for j in [-1..1]
        neighbour = @tiles[tile.row + i]?[tile.col + j]
        if neighbour and rogue.name not in neighbour.explored
          if neighbour.terrain in [symbols.GROUND, symbols.STAIRCASE, symbols.TRAP]
            additionalTiles = @explore rogue, neighbour
            exploredTiles = exploredTiles.concat additionalTiles
          else if tile.terrain isnt symbols.PASSAGE or neighbour.terrain in [symbols.PASSAGE, symbols.DOOR]
            neighbour.explored.push rogue.name
            exploredTiles.push @getDisplayData(neighbour)
    return exploredTiles

  ###
  Returns a two-dimensional array containing the symbols
  currently visible on the level. For unoccupied tiles, the
  visible symbol is the terrain symbol and for occupied tiles
  it is the occupant's symbol (e.g. 'E', if it's an emu).
  ###
  getMap: (rogue) =>
    map = []
    for row in @tiles
      map.push row.map (tile) =>
        if rogue.name in tile.explored then @getSymbol tile else ' '
    return map

  getDisplayData: (tile) =>
    row  : tile.row
    col  : tile.col
    text : @getSymbol tile
    name : tile.occupant.name if tile.occupant?.type is 'ROGUE'

  ###
  Returns the symbol that is visible on the specified tile.
  ###
  getSymbol: (tile) =>
    if tile.occupant then symbols[tile.occupant.type] else tile.terrain
