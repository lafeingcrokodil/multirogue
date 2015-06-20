_ = require 'lodash'

levelData = require './data/levels'

get = (levelNumber) ->
  return levelData[levelNumber - 1]

update = (currLevelNumber, exp) ->
  currLevel = get currLevelNumber
  nextLevel = get currLevelNumber + 1 if currLevelNumber < levelData.length

  if exp < currLevel.minExp or (nextLevel and exp >= nextLevel.minExp) # level has changed
    levelIndex = _.findLastIndex levelData, (level) -> exp >= level.minExp
    return levelIndex + 1
  else
    return currLevelNumber

module.exports = { get, update }
