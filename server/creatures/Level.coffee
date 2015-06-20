_ = require 'lodash'

levels = [
  { minExp: 0, healDice: '1', healDelay: 18 }
  { minExp: 10, healDice: '1', healDelay: 17 }
  { minExp: 20, healDice: '1', healDelay: 15 }
  { minExp: 40, healDice: '1', healDelay: 13 }
  { minExp: 80, healDice: '1', healDelay: 11 }
  { minExp: 160, healDice: '1', healDelay: 9 }
  { minExp: 320, healDice: '1', healDelay: 7 }
  { minExp: 640, healDice: '1', healDelay: 3 }
  { minExp: 1300, healDice: '1d2', healDelay: 3 }
  { minExp: 2600, healDice: '1d3', healDelay: 3 }
  { minExp: 5200, healDice: '1d4', healDelay: 3 }
  { minExp: 13000, healDice: '1d5', healDelay: 3 }
  { minExp: 26000, healDice: '1d6', healDelay: 3 }
  { minExp: 50000, healDice: '1d7', healDelay: 3 }
  { minExp: 100000, healDice: '1d8', healDelay: 3 }
  { minExp: 200000, healDice: '1d9', healDelay: 3 }
  { minExp: 400000, healDice: '1d10', healDelay: 3 }
  { minExp: 800000, healDice: '1d11', healDelay: 3 }
  { minExp: 2000000, healDice: '1d12', healDelay: 3 }
  { minExp: 4000000, healDice: '1d13', healDelay: 3 }
  { minExp: 8000000, healDice: '1d14', healDelay: 3 }
]

get = (levelNumber) ->
  return levels[levelNumber - 1]

update = (currLevelNumber, exp) ->
  currLevel = get currLevelNumber
  nextLevel = get currLevelNumber + 1 if currLevelNumber < levels.length

  if exp < currLevel.minExp or (nextLevel and exp >= nextLevel.minExp) # level has changed
    levelIndex = _.findLastIndex levels, (level) -> exp >= level.minExp
    return levelIndex + 1
  else
    return currLevelNumber

module.exports = { get, update }
