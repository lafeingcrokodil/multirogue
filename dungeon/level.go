package dungeon

import "math/rand/v2"

const length = 80
const breadth = 24

func NewLevel() [][]Tile {
	var ts [][]Tile
	for y := 0; y < breadth; y++ {
		var t []Tile
		for x := 0; x < length; x++ {
			t = append(t, Tile{x: x, y: y, terrain: Floor})
		}
		ts = append(ts, t)
	}
	x, y := staircasePos()
	ts[y][x].terrain = Staircase
	return ts
}

func staircasePos() (x, y int) {
	return rand.IntN(length), rand.IntN(breadth)
}
