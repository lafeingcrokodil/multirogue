roll = (diceStr) ->
  dice = diceStr.split '+'
  total = 0
  for die in dice
    if /^\d+$/.test die
      total += parseInt die, 10
    else if /^\d+d\d+$/.test die
      [number, sides] = die.split 'd'
      if number >= 1
        for i in [1..number]
          total += rollDie sides
  return total

rollDie = (sides) ->
  Math.floor (Math.random() * sides) + 1

module.exports = { roll }
