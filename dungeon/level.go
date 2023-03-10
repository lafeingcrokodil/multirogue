package dungeon

import (
	"github.com/lafeingcrokodil/multirogue/creatures"
	"github.com/lafeingcrokodil/multirogue/terrain"
)

const (
	Lines int = 23
	Cols      = 80
)

type Level struct {
	Tiles [Lines][Cols]Tile
}

func NewLevel(rogue *creatures.Rogue) Level {
	var tiles [Lines][Cols]Tile
	for line := 0; line < Lines; line++ {
		for col := 0; col < Cols; col++ {
			tiles[line][col] = Tile{terrain: terrain.Floor}
		}
	}
	tiles[rogue.Position().Line][rogue.Position().Col].occupant = rogue
	return Level{Tiles: tiles}
}
