class Screen

  constructor: (canvas) ->
    @context = canvas.getContext '2d'

    # get character dimensions
    @charHeight = 12 # character height is fixed
    @charWidth = @getCharWidth()

    # resize canvas according to character dimensions
    canvas.width = 80 * @charWidth
    canvas.height = 24 * @charHeight + 1

    # set font (including size and colour)
    @context.font = @getFont()
    @context.fillStyle = '#FFFFFF'

  getFont: => "#{@charHeight}px Courier New"

  getCharWidth: =>
    @context.font = @getFont()
    return @context.measureText('x').width

  getX: (x) => x * @charWidth

  getY: (y) => (y + 1) * @charHeight

  display: (char, x, y) =>
    @context.clearRect @getX(x), @getY(y-1) + 1, @charWidth, @charHeight
    @context.fillText char, @getX(x), @getY(y)

$(document).ready ->
  screen = new Screen $('#screen')[0]

  socket = io.connect "http://#{location.hostname}:#{location.port}"
  socket.on 'display', (data) ->
    screen.display data.char, data.x, data.y

  $(document).keydown (e) ->
    socket.emit 'key', e.which
    e.preventDefault()
