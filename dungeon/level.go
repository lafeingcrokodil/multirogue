package dungeon

import "math/rand/v2"

const length = 80
const breadth = 22

// NewLevel randomly generates a new dungeon level.
func NewLevel() [][]Tile {
	ts := make([][]Tile, 0, breadth)
	for y := range breadth {
		t := make([]Tile, 0, length)
		for x := range length {
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
