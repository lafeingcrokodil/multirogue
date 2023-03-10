package creatures

import "github.com/lafeingcrokodil/multirogue/position"

type Rogue struct {
	Name string
	pos  position.Position
}

func NewRogue(name string) *Rogue {
	return &Rogue{
		Name: name,
	}
}

func (r *Rogue) Move(pos position.Position) {
	r.pos = pos
}

func (r *Rogue) Position() position.Position {
	return r.pos
}

func (r *Rogue) Rune() rune {
	return '@'
}
