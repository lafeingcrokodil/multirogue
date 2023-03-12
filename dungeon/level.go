package dungeon

import "math/rand"

const Lines = 24
const Cols = 80

func NewLevel() [][]Tile {
	var ts [][]Tile
	for line := 0; line < Lines; line++ {
		var t []Tile
		for col := 0; col < Cols; col++ {
			t = append(t, Tile{terrain: Floor})
		}
		ts = append(ts, t)
	}
	line, col := staircasePos()
	ts[line][col].terrain = Staircase
	return ts
}

func staircasePos() (line, col int) {
	return rand.Intn(Lines), rand.Intn(Cols)
}
