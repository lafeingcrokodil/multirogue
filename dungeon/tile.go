package dungeon

const (
	// Floor is the floor of a room.
	Floor = '.'
	// Staircase leads to adjacent dungeon levels.
	Staircase = '%'
)

// Tile contains information about a specific position in a dungeon.
type Tile struct {
	x        int
	y        int
	terrain  rune
	occupant Creature
}

// Symbol returns the rune representing the visible contents of a tile.
func (t *Tile) Symbol() rune {
	if t.occupant != nil {
		return t.occupant.Symbol()
	}
	return t.terrain
}

// String returns the string representing the visible contents of a tile.
func (t *Tile) String() string {
	return string(t.Symbol())
}
