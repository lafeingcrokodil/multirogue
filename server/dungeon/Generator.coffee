_ = require 'lodash'

ROWS = 23
COLUMNS = 80

Random = require '../Random'

adjacencies =
  0: { 1: 'EAST', 3: 'SOUTH' }
  1: { 0: 'WEST', 2: 'EAST', 4: 'SOUTH' }
  2: { 1: 'WEST', 5: 'SOUTH' }
  3: { 0: 'NORTH', 4: 'EAST', 6: 'SOUTH' }
  4: { 1: 'NORTH', 3: 'WEST', 5: 'EAST', 7: 'SOUTH' }
  5: { 2: 'NORTH', 4: 'WEST', 8: 'SOUTH' }
  6: { 3: 'NORTH', 7: 'EAST' }
  7: { 4: 'NORTH', 6: 'WEST', 8: 'EAST' }
  8: { 5: 'NORTH', 7: 'WEST' }

opposites =
  NORTH : 'SOUTH'
  SOUTH : 'NORTH'
  EAST  : 'WEST'
  WEST  : 'EAST'

generate = ->
  numRooms = Random.getInt 6, 9
  quadrantsWithRooms = _.sample [0..8], numRooms
  quadrants = [0..8].map (index) ->
    { min, max } = getQuadrantBounds index
    if index in quadrantsWithRooms
      room = generateRoom min, max
      return { index, room }
    else
      fixPoint =
        row: Random.getInt min.row + 1, max.row - 1
        col: Random.getInt min.col + 1, max.col - 1
      return { index, fixPoint }

  passages = getPassages quadrants, getEdges()

  staircase = getStaircaseCoords quadrants

  return toString quadrants, passages, staircase

getQuadrantBounds = (index) ->
  min:
    row: Math.floor Math.floor(index/3) * ROWS/3 + 1
    col: Math.floor (index % 3) * COLUMNS/3
  max:
    row: Math.floor((Math.floor(index/3) + 1) * ROWS/3) - 1
    col: Math.floor(((index % 3) + 1) * COLUMNS/3) - 2

generateRoom = (min, max) ->
  topLeft =
    row: Random.getInt min.row, max.row - 4
    col: Random.getInt min.col, max.col - 4
  bottomRight =
    row: Random.getInt topLeft.row + 4, max.row
    col: Random.getInt topLeft.col + 4, max.col
  return { topLeft, bottomRight }

getEdges = ->
  connected = [0]
  remaining = [1..8]

  edges = []
  possibleEdges = ({ source: 0, dest: adjacentIndex } for adjacentIndex in getAdjacentIndices(0))

  while remaining.length
    edge = _.sample possibleEdges
    edges.push edge
    index = edge.dest
    connected.push index
    remaining = remaining.filter (i) -> i isnt index
    possibleEdges = possibleEdges.filter (edge) -> edge.dest isnt index
    for adjacentIndex in getAdjacentIndices(index)
      if adjacentIndex in remaining
        possibleEdges.push { source: index, dest: adjacentIndex }

  for i in [0..8]
    for j in getAdjacentIndices(i)
      continue unless i < j
      edge = { source: i, dest: j }
      missing = edges.every (usedEdge) ->
        not _.isEqual(edge, usedEdge) and not _.isEqual({ source: j, dest: i }, usedEdge)
      if missing and Random.getInt(1, 5) < 3
        edges.push edge

  return edges

getPassages = (quadrants, edges) ->
  edges.map (edge) ->
    direction = adjacencies[edge.source][edge.dest]
    directions = { source: direction, dest: opposites[direction] }
    endpoints = {}
    for x in ['source', 'dest']
      if quadrants[edge[x]].room
        endpoints[x] = getDoorCoords quadrants[edge[x]].room, directions[x]
      else
        endpoints[x] = quadrants[edge[x]].fixPoint
    passage = [endpoints.source, null, null, null, null, endpoints.dest]
    switch direction
      when 'NORTH'
        passage[1] = { row: passage[0].row - 1, col: passage[0].col }
        passage[4] = { row: passage[5].row + 1, col: passage[5].col }
      when 'SOUTH'
        passage[1] = { row: passage[0].row + 1, col: passage[0].col }
        passage[4] = { row: passage[5].row - 1, col: passage[5].col }
      when 'EAST'
        passage[1] = { row: passage[0].row, col: passage[0].col + 1 }
        passage[4] = { row: passage[5].row, col: passage[5].col - 1 }
      when 'WEST'
        passage[1] = { row: passage[0].row, col: passage[0].col - 1 }
        passage[4] = { row: passage[5].row, col: passage[5].col + 1 }
    switch _.sample ['VERTICAL', 'HORIZONTAL'] # initial direction
      when 'VERTICAL'
        minRow = Math.min passage[0].row, passage[5].row
        maxRow = Math.max passage[0].row, passage[5].row
        passage[2] =
          row: Random.getInt minRow + 1, maxRow - 1
          col: passage[1].col
        passage[3] =
          row: passage[2].row
          col: passage[4].col
      when 'HORIZONTAL'
        minCol = Math.min passage[0].col, passage[5].col
        maxCol = Math.max passage[0].col, passage[5].col
        passage[2] =
          row: passage[1].row
          col: Random.getInt minCol + 1, maxCol - 1
        passage[3] =
          row: passage[4].row
          col: passage[2].col
    return passage

getDoorCoords = ({ topLeft, bottomRight }, direction) ->
  switch direction
    when 'NORTH'
      row = topLeft.row
      col = Random.getInt topLeft.col + 1, bottomRight.col - 1
    when 'SOUTH'
      row = bottomRight.row
      col = Random.getInt topLeft.col + 1, bottomRight.col - 1
    when 'EAST'
      row = Random.getInt topLeft.row + 1, bottomRight.row - 1
      col = bottomRight.col
    when 'WEST'
      row = Random.getInt topLeft.row + 1, bottomRight.row - 1
      col = topLeft.col
  return { row, col, isDoor: true }

getAdjacentIndices = (index) ->
  _.keys(adjacencies[index]).map (adjacentIndex) -> parseInt adjacentIndex, 10

getStaircaseCoords = (quadrants) ->
  quadrantsWithRooms = quadrants.filter (quadrant) -> quadrant.room
  { room } = _.sample quadrantsWithRooms

  row: Random.getInt room.topLeft.row + 1, room.bottomRight.row - 1
  col: Random.getInt room.topLeft.col + 1, room.bottomRight.col - 1

toString = (quadrants, passages, staircase) ->
  level = ((' ' for col in [1..COLUMNS]) for row in [1..ROWS])

  for quadrant in quadrants
    continue unless quadrant.room
    { topLeft, bottomRight } = quadrant.room
    for row in [topLeft.row, bottomRight.row]
      for col in [topLeft.col..bottomRight.col]
        level[row][col] = '-'
    for row in [topLeft.row + 1..bottomRight.row - 1]
      for col in [topLeft.col, bottomRight.col]
        level[row][col] = '|'
      for col in [topLeft.col + 1..bottomRight.col - 1]
        level[row][col] = '.'

  for passage in passages
    for vertex, i in passage[0..passage.length - 2]
      nextVertex = passage[i+1]
      if vertex.row isnt nextVertex.row
        for row in [vertex.row..nextVertex.row]
          level[row][vertex.col] = '#'
      else if vertex.col isnt nextVertex.col
        for col in [vertex.col..nextVertex.col]
          level[vertex.row][col] = '#'
    for i in [0, passage.length - 1]
      level[passage[i].row][passage[i].col] = if passage[i].isDoor then '+' else '#'

  level[staircase.row][staircase.col] = '%'

  return (level[row].join '' for row in [0..level.length-1]).join '\n'

unless module.parent
  console.log generate()
