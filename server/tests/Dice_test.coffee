should = require 'should'

Dice = require '../Dice'

describe 'Dice', ->

  describe '#roll()', ->

    NUM_ATTEMPTS = 100 # try multiple times to reduce likelihood of false positives
  
    it 'should return the specified number if the input represents a number', ->
      for i in [1..NUM_ATTEMPTS]
        Dice.roll('0').should.equal 0
        Dice.roll('23').should.equal 23
  
    it 'should return a number between x and x*y if the input is "xdy"', ->
      for i in [1..NUM_ATTEMPTS]
        Dice.roll('0d0').should.equal 0
        Dice.roll('1d8').should.be.within 1, 8
        Dice.roll('2d8').should.be.within 2, 16
        Dice.roll('3d8').should.be.within 3, 24
  
    it 'should add up results if the input is "xdy+..."', ->
      for i in [1..NUM_ATTEMPTS]
        Dice.roll('1d8+2d8+3d8').should.be.within 6, 48
