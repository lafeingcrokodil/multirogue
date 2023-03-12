package creature

// Position specifies a position in a dungeon.
type Position struct {
	// Level is the level of the dungeon.
	Level int
	// Line is the position on the y axis within the level.
	Line int
	// Col is the position on the x axis within the level.
	Col int
}
