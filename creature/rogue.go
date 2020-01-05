package creature

// Rogue is an adventurer in a dungeon.
type Rogue struct {
	// Name is the rogue's name.
	Name string
	// Pos is the rogues position in the dungeon.
	Pos *Position
}

// NewRogue creates a new rogue with the specified name.
func NewRogue(name string) *Rogue {
	return &Rogue{Name: name}
}

func (r *Rogue) Position() *Position {
	return r.Pos
}

func (r *Rogue) Rune() rune {
	return '@'
}

func (r *Rogue) SetPosition(pos *Position) {
	r.Pos = pos
}
