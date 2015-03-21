class Screen

  constructor: (canvas, @rows, @cols) ->
    @context = canvas.getContext '2d'

    # get character dimensions
    @charHeight = 12 # character height is fixed
    @charWidth = @getTextWidth 'x'

    # resize canvas according to character dimensions
    @width = canvas.width = cols * @charWidth
    @height = canvas.height = (rows + 2) * @charHeight

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

  displayStats: (text) =>
    @context.clearRect 0, @getY(@rows-1) + 1, @width, @charHeight
    @context.fillText text, 0, @getY(@rows)

  displayMap: (map) =>
    for mapRow, row in map
      for char, col in mapRow
        @display char, row, col

$(document).ready ->
  socket = io.connect "//#{location.host}"

  socket.on 'map', (mapData) ->
    screen = new Screen $('#screen')[0], mapData.rows, mapData.cols
    $('#screen').css 'display', 'block' # make screen visible
    screen.displayMap mapData.map
    socket.on 'display', (data) ->
      screen.display data.char, data.row, data.col
    socket.on 'stats', (data) ->
      screen.displayStats "HP: #{data.hp}"

  $(document).keydown (e) ->
    socket.emit 'key', e.which
    e.preventDefault()
