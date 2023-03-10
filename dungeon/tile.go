package dungeon

import (
	"github.com/lafeingcrokodil/multirogue/terrain"
)

type Tile struct {
	occupant Occupant
	terrain  terrain.Terrain
}

func (t Tile) Rune() rune {
	switch {
	case t.occupant != nil:
		return t.occupant.Rune()
	default:
		return rune(t.terrain)
	}
}
