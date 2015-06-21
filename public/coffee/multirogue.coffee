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

  display: (text, row, col, name) =>
    if name and name isnt @playerName
      @context.fillStyle = 'grey'
    @context.clearRect @getX(col), @getY(row-1) + 1, @getTextWidth(text), @charHeight
    @context.fillText text, @getX(col), @getY(row)
    @context.fillStyle = 'white'

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

  displayLevel: ({ map, rogues }) =>
    for mapRow, row in map
      for char, col in mapRow
        @display char, row, col
    for rogue in rogues
      @display '@', rogue.row, rogue.col, rogue.name

  pad: (str, length) ->
    if length > str.length
      str += (' ' for i in [1..length-str.length]).join('')
    else
      str

$(document).ready ->
  socket = io()

  playerName = ''

  validate = (name, players) ->
    unless 1 <= name.length <= 20
      errMsg = 'Please enter a name with between 1 and 20 characters'
    else if name in players
      plural = if /(sh?|ch|x|z)$/.test name then 'es' else 's'
      errMsg = "The dungeon is not big enough for two #{name}#{plural}! Please choose a different name"
    return errMsg + ' and press ENTER to continue.' if errMsg

  socket.on 'players', (players) ->
    $('#screen').hide()
    nameForm = $('#nameForm')
    nameForm.show()
    nameInput = $('#nameForm input')
    nameInput.focus()
    nameForm.submit (event) ->
      playerName = nameInput.val()
      newPrompt = validate playerName, players
      if newPrompt
        $('#nameForm p').text newPrompt
      else
        nameInput.blur()
        nameForm.hide()
        socket.emit 'join', playerName
      return false

  socket.on 'level', (level) ->
    screen = new Screen $('#screen')[0], level, playerName
    $('#screen').css 'display', 'block'
    socket.on 'display', ({ char, row, col, name }) ->
      screen.display char, row, col, name
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
