should = require 'should'

Random = require '../Random'

describe 'Random', ->

  NUM_ATTEMPTS = 100 # try multiple times to reduce likelihood of false positives

  describe '#roll()', ->
  
    it 'should return the specified number if the input represents a number', ->
      for i in [1..NUM_ATTEMPTS]
        Random.roll('0').should.equal 0
        Random.roll('23').should.equal 23
  
    it 'should return a number between x and x*y if the input is "xdy"', ->
      for i in [1..NUM_ATTEMPTS]
        Random.roll('0d0').should.equal 0
        Random.roll('1d8').should.be.within 1, 8
        Random.roll('2d8').should.be.within 2, 16
        Random.roll('3d8').should.be.within 3, 24
  
    it 'should add up results if the input is "xdy+..."', ->
      for i in [1..NUM_ATTEMPTS]
        Random.roll('1d8+2d8+3d8').should.be.within 6, 48

  describe '#getInt()', ->
  
    it 'should return a number between x and y (inclusive)', ->
      for i in [1..NUM_ATTEMPTS]
        Random.getInt(2, 2).should.equal 2
        Random.getInt(0, 5).should.be.within 0, 5
        Random.getInt(5, 10).should.be.within 5, 10
