package dungeon

import (
	"fmt"
	"math/rand"
	"time"

	"github.com/lafeingcrokodil/multirogue/creature"
	"github.com/lafeingcrokodil/multirogue/event"
)

// Creature is a living occupant of the dungeons.
type Creature interface {
	// Position returns the rogue's position in the dungeon.
	Position() *creature.Position
	// Rune returns the rune representing the rogue.
	Rune() rune
	// SetPosition sets the rogues position in the dungeon.
	SetPosition(pos *creature.Position)
}

// Dungeon is a randomly generated set of rooms, passages, monsters and
// items spread over multiple levels.
type Dungeon struct {
	tiles [][][]Tile
}

// New just generates a dungeon with one blank level for now.
func New() *Dungeon {
	rand.Seed(time.Now().UnixNano())
	var ts [][]Tile
	for y := 0; y < 24; y++ {
		var t []Tile
		for x := 0; x < 80; x++ {
			t = append(t, Tile{x: x, y: y, terrain: Floor})
		}
		ts = append(ts, t)
	}
	return &Dungeon{
		tiles: [][][]Tile{ts},
	}
}

// Add places a rogue in a dungeon.
func (d *Dungeon) Add(r *creature.Rogue) (send, broadcast []*event.Event) {
	d.occupy(r, d.randomSpawnPos(0))
	return []*event.Event{&event.Event{
			Name: "level",
			Data: fmt.Sprintf(`{"map":"%s"}`, d.Map(r)),
		}}, []*event.Event{&event.Event{
			Level: &r.Pos.Level,
			Name:  "display",
			Data: fmt.Sprintf(`{"x": "%d", "y": "%d", "c": "%c"}`,
				r.Pos.X,
				r.Pos.Y,
				d.tiles[r.Pos.Level][r.Pos.Y][r.Pos.X].Rune()),
		}}
}

// Remove removes a rogue from a dungeon.
func (d *Dungeon) Remove(r *creature.Rogue) (send, broadcast []*event.Event) {
	d.unoccupy(r)
	return nil, []*event.Event{&event.Event{
		Level: &r.Pos.Level,
		Name:  "display",
		Data: fmt.Sprintf(`{"x": "%d", "y": "%d", "c": "%c"}`,
			r.Pos.X,
			r.Pos.Y,
			d.tiles[r.Pos.Level][r.Pos.Y][r.Pos.X].Rune()),
	}}
}

// Map returns a string representation of the level.
func (d *Dungeon) Map(r *creature.Rogue) string {
	var m string
	for y := 0; y < len(d.tiles[r.Pos.Level]); y++ {
		for x := 0; x < len(d.tiles[r.Pos.Level][y]); x++ {
			m += string(d.tiles[r.Pos.Level][y][x].Rune())
		}
		m += "\\n"
	}
	return m
}

func (d *Dungeon) occupy(c Creature, pos *creature.Position) {
	d.tiles[pos.Level][pos.Y][pos.X].occupant = c
	c.SetPosition(pos)
}

func (d *Dungeon) unoccupy(c Creature) {
	pos := c.Position()
	d.tiles[pos.Level][pos.Y][pos.X].occupant = nil
}

func (d *Dungeon) randomSpawnPos(level int) *creature.Position {
	for {
		x := rand.Intn(len(d.tiles[level][0]))
		y := rand.Intn(len(d.tiles[level]))
		if d.isValidSpawnPos(level, x, y) {
			return &creature.Position{
				Level: level,
				X:     x,
				Y:     y,
			}
		}
	}
}

func (d *Dungeon) isValidSpawnPos(level, x, y int) bool {
	return d.tiles[level][y][x].Rune() == Floor
}
