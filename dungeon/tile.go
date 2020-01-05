package dungeon

const (
	// Floor is the floor of a room.
	Floor = '.'
)

// Tile contains information about a specific position in a dungeon.
type Tile struct {
	x       int
	y       int
	terrain rune
}

// Rune returns the rune representing the visible contents of a tile.
func (t *Tile) Rune() rune {
	return t.terrain
}
