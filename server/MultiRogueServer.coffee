fs   = require 'fs'
path = require 'path'

class MultiRogueServer
  module.exports = MultiRogueServer

  rogues: []
  monsters: []

  movedCount: 0
  turnCount: 0

  constructor: ->
    # load key code mapping
    keyCodeStr = fs.readFileSync path.join('server', 'keyCodes.json'), 'utf8'
    @keyCodes = JSON.parse keyCodeStr

    # load symbol dictionary
    symbolStr = fs.readFileSync path.join('server', 'symbols.json'), 'utf8'
    @symbols = JSON.parse symbolStr

    @loadTerrain 'oneRoom'

  loadTerrain: (mapName) =>
    # load map file
    mapFile = fs.readFileSync path.join('server', 'maps', "#{mapName}.txt"), 'utf8'

    # initialize map with terrain
    @map = []
    for row in mapFile.split /[\r\n]+/
      mapRow = []
      for char in row
        mapRow.push { terrain: char }
      @map.push mapRow

    # calculate map size
    @mapRows = @map.length
    @mapCols = @map[0].length

  getSimpleMap: =>
    map = []
    for row in @map
      mapRow = []
      for pos in row
        mapRow.push (if pos.occupant then @symbols[pos.occupant.type] else pos.terrain)
      map.push mapRow
    return map

  broadcast: (event, data) =>
    for rogue in @rogues
      rogue.socket.emit event, data

  handleConnection: (socket) =>
    rogue = @addRogue socket
    socket.emit 'map', { map: @getSimpleMap(), rows: @mapRows, cols: @mapCols }
    socket.on 'key', @handleKeyEvent(rogue)
    socket.on 'disconnect', @removeRogue(rogue)

  handleKeyEvent: (rogue) => (code) =>
    switch code
      when @keyCodes.H, @keyCodes.NUMPAD_4
        @move rogue, 0, -1
      when @keyCodes.L, @keyCodes.NUMPAD_6
        @move rogue, 0, 1
      when @keyCodes.K, @keyCodes.NUMPAD_8
        @move rogue, -1, 0
      when @keyCodes.J, @keyCodes.NUMPAD_2
        @move rogue, 1, 0
      when @keyCodes.Y, @keyCodes.NUMPAD_7
        @move rogue, -1, -1
      when @keyCodes.U, @keyCodes.NUMPAD_9
        @move rogue, -1, 1
      when @keyCodes.B, @keyCodes.NUMPAD_1
        @move rogue, 1, -1
      when @keyCodes.N, @keyCodes.NUMPAD_3
        @move rogue, 1, 1
      when @keyCodes.PERIOD, @keyCodes.NUMPAD_5
        if rogue.canMove
          rogue.canMove = false
          do @handleEndMove

  addRogue: (socket) =>
    console.log "[#{socket.handshake.address.address}] Rogue joined."
    newRogue = { socket, type: 'ROGUE', canMove: true }
    { row, col } = @getRandomSpawnPos()
    @occupy row, col, newRogue
    @rogues.push newRogue
    return newRogue

  removeRogue: (rogue) => () =>
    console.log "[#{rogue.socket.handshake.address.address}] Rogue left."
    index = @rogues.indexOf rogue
    @rogues.splice index, 1
    @removeOccupant rogue.row, rogue.col

  spawnMonster: (type) =>
    newMonster = { type, canMove: true }
    { row, col } = @getRandomSpawnPos()
    @occupy row, col, newMonster
    @monsters.push newMonster

  getRandomSpawnPos: =>
    loop # trial and error
      row = Math.floor (@mapRows * Math.random())
      col = Math.floor (@mapCols * Math.random())
      break if @isValid row, col
    return { row, col }

  isValid: (row, col) =>
    inBounds = 0 <= row < @mapRows and 0 <= col < @mapCols
    terrainOK = @map[row][col].terrain in [
      @symbols.GROUND,
      @symbols.DOOR,
      @symbols.PASSAGE,
      @symbols.TRAP
    ]
    notOccupied = not @map[row][col].occupant
    return inBounds and terrainOK and notOccupied

  move: (creature, dRow, dCol) =>
    return unless creature.canMove
    oldPos = { row: creature.row, col: creature.col }
    newPos = { row: oldPos.row + dRow, col: oldPos.col + dCol }
    return unless @isValid newPos.row, newPos.col
    creature.canMove = false if creature.type is 'ROGUE'
    @removeOccupant oldPos.row, oldPos.col
    @occupy newPos.row, newPos.col, creature
    do @handleEndMove if creature.type is 'ROGUE'

  moveMonsters: =>
    for monster, i in @monsters
      if @rogues.length > 0
        target = @rogues[i % @rogues.length]
        dRow = @compare target.row, monster.row
        dCol = @compare target.col, monster.col
        @move monster, dRow, dCol

  compare: (a, b) =>
    if a < b then -1 else if a > b then 1 else 0

  removeOccupant: (row, col) =>
    @map[row][col].occupant = false
    @broadcast 'display', { char: @map[row][col].terrain, row, col }

  occupy: (row, col, occupant) =>
    @map[row][col].occupant = occupant
    occupant.row = row
    occupant.col = col
    @broadcast 'display', { char: @symbols[occupant.type], row, col }

  handleEndMove: =>
    if (++@movedCount) is @rogues.length
      do @handleNewTurn
      @movedCount = 0
      for rogue in @rogues
        rogue.canMove = true

  handleNewTurn: =>
    @turnCount++
    if @turnCount % 10 is 0
      @spawnMonster 'EMU'
    do @moveMonsters
