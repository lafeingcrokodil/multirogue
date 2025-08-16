// Package creature contains logic related to creatures that inhabit the dungeon.
package creature

// Position specifies a position in a dungeon.
type Position struct {
	// Level is the level of the dungeon.
	Level int
	// X is the position on the x axis within the level.
	X int
	// Y is the position on the y axis within the level.
	Y int
}
