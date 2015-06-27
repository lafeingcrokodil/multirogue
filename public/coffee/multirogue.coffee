playerName = ''
socket = io()
screen = null
messages = []

$(document).ready ->
  socket.on 'players', pickName
  socket.on 'level', setupLevel
  socket.on 'notify', displayNotification
  socket.on 'narration', (msgArray) ->
    messages = messages.concat msgArray
    screen.displayNarration messages.shift()
  socket.on 'display', (data) -> screen?.display data
  socket.on 'stats', (stats) -> screen?.displayStats stats

pickName = (existingPlayers) ->
  $('#nameForm').show().submit (event) ->
    try
      playerName = $('#nameInput').val()
      newPrompt = validate playerName, existingPlayers
      if newPrompt
        $('#nameForm p').text newPrompt
        $('#nameInput').val ''
      else
        $('#nameInput').blur()
        $('#nameForm').hide()
        socket.emit 'join', playerName
        addKeyListener()
    catch err
      console.error err
    return false # don't reload page

validate = (name, existingPlayers) ->
  unless name
    errMsg = 'Please choose a name with at least one character'
  else if name in existingPlayers
    plural = if /(sh?|ch|x|z)$/.test name then 'es' else 's'
    errMsg = "The dungeon is not big enough for two #{name}#{plural}! Please choose a different name"
  return errMsg + ' and press ENTER to continue.' if errMsg

addKeyListener = ->
  $(document).keypress (e) ->
    charCode = String.fromCharCode(e.charCode) # TODO: check browser compatibility
    if messages.length and charCode is ' '
      screen.displayNarration messages.shift()
      e.preventDefault()
    else unless messages.length
      switch charCode
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
        else return # don't prevent default for unrecognized keys
      e.preventDefault()

displayNotification = (notification) ->
  $('#notifications').append "> #{notification}\n"
  $('#notifications').scrollTop $('#notifications')[0].scrollHeight

setupLevel = (level) ->
  socket.removeEventListener 'players', pickName
  screen = new Screen $('canvas')[0], level, playerName
  $('#container').show()

class Screen

  constructor: (canvas, level, @playerName) ->
    @context = canvas.getContext '2d'

    @currLevel = level.name

    @charHeight = 12 # character height is fixed
    @charWidth = @getTextWidth 'x'

    @rows = level.map.length
    @cols = level.map[0].length

    @width = canvas.width = @cols * @charWidth
    @height = canvas.height = (@rows + 2) * @charHeight

    @context.font = @getFont()
    @context.fillStyle = 'white'

    @displayLevel level

  getFont: => "#{@charHeight}px Courier New"

  getTextWidth: (text) =>
    @context.font = @getFont()
    return @context.measureText(text).width

  getX: (col) => col * @charWidth

  getY: (row) => (row + 1) * @charHeight

  display: ({ text, row, col, name }) =>
    if name and name isnt @playerName
      @context.fillStyle = 'grey'
    @context.clearRect @getX(col), @getY(row-1) + 1, @getTextWidth(text), @charHeight
    @context.fillText text, @getX(col), @getY(row)
    @context.fillStyle = 'white'

  displayNarration: (message) =>
    message += '--More--' if messages.length
    @context.clearRect 0, 1, @width, @charHeight + 1
    @context.fillText message, 0, @getY(0)

  displayStats: (stats) =>
    hp = "#{stats.hitPoints}(#{stats.maxHitPoints})"
    str = "#{stats.strength}(#{stats.maxStrength})"
    exp = "#{stats.level}/#{stats.experience}"
    statStr = ''
    statStr += "Lvl: #{@pad(@currLevel, 4)}"
    statStr += "Gold: #{@pad(stats.gold.toString(), 8)}"
    statStr += "Hp: #{@pad(hp, 10)}"
    statStr += "Str: #{@pad(str, 8)}"
    statStr += "Arm: #{@pad(stats.armourClass.toString(), 4)}"
    statStr += "Exp: #{exp}"
    @context.clearRect 0, @getY(@rows-1) + 1, @width, @charHeight + 1
    @context.fillText statStr, 0, @getY(@rows)

  displayLevel: ({ map, rogues }) =>
    for mapRow, row in map
      for char, col in mapRow
        @display { text: char, row, col }
    for rogue in rogues
      @display { text: '@', row: rogue.row, col: rogue.col, name: rogue.name }

  pad: (str, length) ->
    if length > str.length
      str += (' ' for i in [1..length-str.length]).join('')
    else
      str
