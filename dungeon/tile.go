package dungeon

const (
	// Floor is the floor of a room.
	Floor = '.'
)

// Tile contains information about a specific position in a dungeon.
type Tile struct {
	x        int
	y        int
	terrain  rune
	occupant Creature
}

// Rune returns the rune representing the visible contents of a tile.
func (t *Tile) Rune() rune {
	if t.occupant != nil {
		return t.occupant.Rune()
	}
	return t.terrain
}

// String returns the string representing the visible contents of a tile.
func (t *Tile) String() string {
	return string(t.Rune())
}
