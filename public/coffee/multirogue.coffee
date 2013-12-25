class Screen

  constructor: (canvas) ->
    @context = canvas.getContext '2d'

    # get character dimensions
    @charHeight = 12 # character height is fixed
    @charWidth = @getCharWidth()

    # resize canvas according to character dimensions
    canvas.width = 80 * @charWidth
    canvas.height = 24 * @charHeight

    # set font (including size and colour)
    @context.font = @getFont()
    @context.fillStyle = '#FFFFFF'

  getFont: => "#{@charHeight}px Courier New"

  getCharWidth: =>
    @context.font = @getFont()
    return @context.measureText('x').width

  display: (char, x, y) =>
    actualX = x * @charWidth
    actualY = (y + 1) * @charHeight
    @context.fillText char, actualX, actualY

$(document).ready ->
  screen = new Screen $('#screen')[0]

  socket = io.connect "http://#{window.location.hostname}:13375"
  socket.on 'display', (data) ->
    screen.display data.char, data.x, data.y
