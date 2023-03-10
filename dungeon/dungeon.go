package dungeon

import (
	"github.com/lafeingcrokodil/multirogue/creatures"
	"github.com/lafeingcrokodil/multirogue/position"
)

type Dungeon struct {
	Levels []Level
	Rogue  *creatures.Rogue
}

func NewDungeon(rogueName string) *Dungeon {
	rogue := creatures.NewRogue(rogueName)
	return &Dungeon{
		Levels: []Level{NewLevel(rogue)},
		Rogue:  rogue,
	}
}

func (d Dungeon) CurrentLevel() Level {
	return d.Levels[d.Rogue.Position().Level]
}

func (d Dungeon) MoveRogue(dLevel, dLine, dCol int) {
	d.move(d.Rogue, dLevel, dLine, dCol)
}

func (d Dungeon) move(o Occupant, dLevel, dLine, dCol int) {
	oldPos := o.Position()
	newPos := position.Position{
		Level: oldPos.Level + dLevel,
		Line:  oldPos.Line + dLine,
		Col:   oldPos.Col + dCol,
	}

	if newPos.Line < 0 || newPos.Line >= Lines || newPos.Col < 0 || newPos.Col >= Cols {
		return
	}

	newTile := &d.Levels[newPos.Level].Tiles[newPos.Line][newPos.Col]

	if newTile.occupant != nil {
		return
	}

	d.Levels[oldPos.Level].Tiles[oldPos.Line][oldPos.Col].occupant = nil
	newTile.occupant = o
	o.Move(newPos)
}
