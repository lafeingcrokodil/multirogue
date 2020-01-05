package dungeon

// Dungeon is a randomly generated set of rooms, passages, monsters and
// items spread over multiple levels.
type Dungeon struct {
	Levels []*Level
}

// New randomly generates a dungeon.
func New() *Dungeon {
	return &Dungeon{
		Levels: []*Level{newLevel()},
	}
}
