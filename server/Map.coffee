fs   = require 'fs'
path = require 'path'

class Map
  module.exports = Map

  constructor: ->
    @tiles = @loadFromFile 'oneRoom'

    # calculate map size
    @rows = @tiles.length
    @cols = @tiles[0].length

    # load symbol dictionary
    symbolStr = fs.readFileSync path.join('server', 'symbols.json'), 'utf8'
    @symbols = JSON.parse symbolStr

  loadFromFile: (mapName) =>
    mapFile = fs.readFileSync path.join('server', 'maps', "#{mapName}.txt"), 'utf8'

    tiles = []
    for row in mapFile.split /[\r\n]+/
      tiles.push row.split('').map (char) => { terrain: char }

    return tiles

  getSnapshot: =>
    snapshot = []
    for row in @tiles
      snapshot.push row.map (tile) => @getSymbol tile
    return snapshot

  isValid: (row, col) =>
    inBounds = 0 <= row < @rows and 0 <= col < @cols
    terrainOK = @tiles[row][col].terrain in [
      @symbols.GROUND,
      @symbols.DOOR,
      @symbols.PASSAGE,
      @symbols.TRAP
    ]
    notOccupied = not @tiles[row][col].occupant
    return inBounds and terrainOK and notOccupied

  occupy: (occupant, row, col) =>
    unless row? and col?
      { row, col } = @getRandomSpawnPos()
    @tiles[row][col].occupant = occupant
    occupant.row = row
    occupant.col = col
    return { char: @symbolAt(row, col), row, col }

  getRandomSpawnPos: =>
    loop # trial and error
      row = Math.floor (@rows * Math.random())
      col = Math.floor (@cols * Math.random())
      break if @isValid row, col
    return { row, col }

  unoccupy: (row, col) =>
    @tiles[row][col].occupant = null
    return { char: @symbolAt(row, col) }

  symbolAt: (row, col) =>
    @getSymbol @tiles[row][col]

  getSymbol: (tile) =>
    if tile.occupant then @symbols[tile.occupant.type] else tile.terrain
