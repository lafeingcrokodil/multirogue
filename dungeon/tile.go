package dungeon

const (
	// Door is a door to/from a room.
	Door = '+'
	// Floor is the floor of a room.
	Floor = '.'
	// HorizontalWall is the wall of a room.
	HorizontalWall = '-'
	// NoMansLand is unreachable terrain.
	NoMansLand = ' '
	//NoMansLand = '\u00A0' // non-breaking space (more importantly, non-collapsing)
	// Passage is the floor of a passage between rooms.
	Passage = '#'
	// Staircase leads to adjacent dungeon levels.
	Staircase = '%'
	// VerticalWall is the wall of a room.
	VerticalWall = '|'
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
