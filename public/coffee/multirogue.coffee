class Screen

  constructor: (canvas, @rows, @cols) ->
    @context = canvas.getContext '2d'

    # get character dimensions
    @charHeight = 12 # character height is fixed
    @charWidth = @getTextWidth 'x'

    # resize canvas according to character dimensions
    @width = canvas.width = @cols * @charWidth
    @height = canvas.height = (@rows + 2) * @charHeight

    # set font (including size and colour)
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
    statStr += "Lvl: #{@pad(stats.dungeonLevel, 4)}"
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

  socket.on 'map', (map) ->
    screen = new Screen $('#screen')[0], map.length, map[0].length
    $('#screen').css 'display', 'block' # make screen visible
    screen.displayMap map
    socket.on 'display', ({ char, row, col }) ->
      screen.display char, row, col
    socket.on 'stats', screen.displayStats

  $(document).keydown (e) ->
    socket.emit 'key', e.which
    e.preventDefault()
