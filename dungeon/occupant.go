package dungeon

import "github.com/lafeingcrokodil/multirogue/position"

type Occupant interface {
	Move(position.Position)
	Position() position.Position
	Rune() rune
}
