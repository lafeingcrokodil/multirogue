class Screen

  constructor: (canvas, level) ->
    @context = canvas.getContext '2d'

    @currLevel = level.name

    @charHeight = 12 # character height is fixed
    @charWidth = @getTextWidth 'x'

    @rows = level.map.length
    @cols = level.map[0].length

    @width = canvas.width = @cols * @charWidth
    @height = canvas.height = (@rows + 2) * @charHeight

    @context.font = @getFont()
    @context.fillStyle = '#FFFFFF'

  getFont: => "#{@charHeight}px Courier New"

  getTextWidth: (text) =>
    @context.font = @getFont()
    return @context.measureText(text).width

  getX: (col) => col * @charWidth

  getY: (row) => (row + 1) * @charHeight

  display: (text, row, col) =>
    @context.clearRect @getX(col), @getY(row-1) + 1, @getTextWidth(text), @charHeight
    @context.fillText text, @getX(col), @getY(row)

  displayStats: (stats) =>
    hp = "#{stats.hitPoints}(#{stats.maxHitPoints})"
    str = "#{stats.strength}(#{stats.maxStrength})"
    exp = "#{stats.level}/#{stats.experience}"
    statStr = ''
    statStr += "Lvl: #{@pad(@currLevel, 4)}"
    statStr += "Gold: #{@pad(stats.gold.toString(), 8)}"
    statStr += "HP: #{@pad(hp, 10)}"
    statStr += "Str: #{@pad(str, 8)}"
    statStr += "Arm: #{@pad(stats.armourClass.toString(), 4)}"
    statStr += "Exp: #{exp}"
    @context.clearRect 0, @getY(@rows-1) + 1, @width, @charHeight
    @context.fillText statStr, 0, @getY(@rows)

  displayMap: (map) =>
    for mapRow, row in map
      for char, col in mapRow
        @display char, row, col

  pad: (str, length) ->
    if length > str.length
      str += (' ' for i in [1..length-str.length]).join('')
    else
      str

$(document).ready ->
  socket = io()

  socket.on 'level', (level) ->
    screen = new Screen $('#screen')[0], level
    $('#screen').css 'display', 'block' # make screen visible
    screen.displayMap level.map
    socket.on 'display', ({ char, row, col }) ->
      screen.display char, row, col
    socket.on 'stats', screen.displayStats

  $(document).keypress (e) ->
    e.preventDefault()
    # TODO: check browser compatibility
    key = String.fromCharCode(e.charCode)
    switch key
      when 'h', '4'
        socket.emit 'move', { dRow: 0, dCol: -1 }  # move left
      when 'l', '6'
        socket.emit 'move', { dRow: 0, dCol: 1 }   # move right
      when 'k', '8'
        socket.emit 'move', { dRow: -1, dCol: 0 }  # move up
      when 'j', '2'
        socket.emit 'move', { dRow: 1, dCol: 0 }   # move down
      when 'y', '7'
        socket.emit 'move', { dRow: -1, dCol: -1 } # move diagonally up and left
      when 'u', '9'
        socket.emit 'move', { dRow: -1, dCol: 1 }  # move diagonally up and right
      when 'b', '1'
        socket.emit 'move', { dRow: 1, dCol: -1 }  # move diagonally down and left
      when 'n', '3'
        socket.emit 'move', { dRow: 1, dCol: 1 }   # move diagonally down and right
      when '.', '5'
        socket.emit 'move', { dRow: 0, dCol: 0 }   # rest (no movement)
      when '>'
        socket.emit 'staircase', { direction: 'down' } # go down staircase
