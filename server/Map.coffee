fs   = require 'fs'
path = require 'path'

symbols = require './data/symbols'

class Map
  module.exports = Map

  constructor: ->
    @tiles = @loadFromFile 'oneRoom'

    # calculate map size
    @rows = @tiles.length
    @cols = @tiles[0].length

  loadFromFile: (mapName) =>
    mapFile = fs.readFileSync path.join('server', 'maps', "#{mapName}.txt"), 'utf8'

    tiles = []
    for row in mapFile.split /[\r\n]+/
      tiles.push row.split('').map (char) => { terrain: char }

    return tiles

  ###
  Places the specified occupant at the specified position.
  If no position is provided, a valid position is chosen
  randomly.

  OUTPUT
    char: the symbol that is now visible at the occupant's
          new position -- usually the occupant's symbol
    row:  first coordinate of the occupant's new position
    col:  second coordinate of the occupant's new position
  ###
  occupy: (occupant, row, col) =>
    unless row? and col?
      { row, col } = @getRandomSpawnPos()
    @tiles[row][col].occupant = occupant
    occupant.row = row
    occupant.col = col
    return { char: @symbolAt(row, col), row, col }

  ###
  Removes whatever creature is currently occupying
  the specified position.

  OUTPUT
    char: the symbol that is visible at the now unoccupied
          position -- usually the underlying terrain symbol
  ###
  unoccupy: (row, col) =>
    @tiles[row][col].occupant = null
    return { char: @symbolAt(row, col) }

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
  currently visible on the map. For unoccupied tiles, the
  visible symbol is the terrain symbol and for occupied tiles
  it is the occupant's symbol (e.g. 'E', if it's an emu).
  ###
  getSnapshot: =>
    snapshot = []
    for row in @tiles
      snapshot.push row.map (tile) => @getSymbol tile
    return snapshot

  ###
  Returns the symbol that is visible at the specified position.
  ###
  symbolAt: (row, col) =>
    @getSymbol @tiles[row][col]

  ###
  Returns the symbol that is visible on the specified map tile.
  ###
  getSymbol: (tile) =>
    if tile.occupant then symbols[tile.occupant.type] else tile.terrain
