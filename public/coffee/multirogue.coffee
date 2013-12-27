class Screen

  constructor: (canvas, rows, cols) ->
    @context = canvas.getContext '2d'

    # get character dimensions
    @charHeight = 12 # character height is fixed
    @charWidth = @getCharWidth()

    # resize canvas according to character dimensions
    canvas.width = cols * @charWidth
    canvas.height = (rows + 2) * @charHeight

    # set font (including size and colour)
    @context.font = @getFont()
    @context.fillStyle = '#FFFFFF'

  getFont: => "#{@charHeight}px Courier New"

  getCharWidth: =>
    @context.font = @getFont()
    return @context.measureText('x').width

  getX: (col) => col * @charWidth

  getY: (row) => (row + 1) * @charHeight

  display: (char, row, col) =>
    @context.clearRect @getX(col), @getY(row-1) + 1, @charWidth, @charHeight
    @context.fillText char, @getX(col), @getY(row)

  displayMap: (map) =>
    for mapRow, row in map
      for char, col in mapRow
        @display char, row, col

$(document).ready ->
  socket = io.connect "http://#{location.hostname}:#{location.port}"

  socket.on 'map', (mapData) ->
    screen = new Screen $('#screen')[0], mapData.rows, mapData.cols
    $('#screen').css 'display', 'block' # make screen visible
    screen.displayMap mapData.map
    socket.on 'display', (data) ->
      screen.display data.char, data.row, data.col

  $(document).keydown (e) ->
    socket.emit 'key', e.which
    e.preventDefault()
