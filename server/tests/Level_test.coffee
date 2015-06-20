should = require 'should'

Level = require '../creatures/Level'

describe 'Level', ->

  describe '#get()', ->

    it 'should return valid level data for levels 1 to 21', ->
      for levelNumber in [1..21]
        level = Level.get levelNumber
        level.should.be.an.Object()
        for property in ['minExp', 'healDice', 'healDelay']
          level.should.have.property property
        level.minExp.should.be.a.Number().which.is.not.below 0
        level.healDice.should.be.a.String().and.match /^\d+(d\d+)?$/
        level.healDelay.should.be.a.Number().which.is.above 0

  describe '#update()', ->

    it 'should return 1 if exp < 10', ->
      for currLevel in [1..21]
        for exp in [0..9]
          Level.update(currLevel, exp).should.equal 1

    it 'should return 2 if 10 <= exp < 20', ->
      for currLevel in [1..21]
        for exp in [10..19]
          Level.update(currLevel, exp).should.equal 2

    it 'should return 20 if 4000000 <= exp < 8000000', ->
      for currLevel in [1..21]
        for exp in [4000000, 4000001, 7999999]
          Level.update(currLevel, exp).should.equal 20

    it 'should return 21 if exp >= 8000000', ->
      for currLevel in [1..21]
        for exp in [8000000, 8000001, 10000000]
          Level.update(currLevel, exp).should.equal 21
