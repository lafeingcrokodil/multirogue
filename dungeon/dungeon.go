// Package dungeon contains logic related to the dungeon and its levels.
package dungeon

import (
	"math/rand/v2"

	"github.com/lafeingcrokodil/multirogue/creature"
	"github.com/lafeingcrokodil/multirogue/event"
)

// numLevels is the number of levels in the dungeon.
const numLevels = 21

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

// New just generates a dungeon with blank levels for now.
func New() *Dungeon {
	var tiles [][][]Tile
	for range numLevels {
		tiles = append(tiles, NewLevel())
	}
	return &Dungeon{tiles: tiles}
}

// Add places a rogue in a dungeon.
func (d *Dungeon) Add(r *creature.Rogue) (send, broadcast []*event.Event) {
	d.occupy(r, d.randomSpawnPos(0))
	return []*event.Event{
			d.newLevelEvent(r),
			d.newStatsEvent(r),
		}, []*event.Event{
			d.newDisplayEvent(r.Pos),
		}
}

// Remove removes a rogue from a dungeon.
func (d *Dungeon) Remove(r *creature.Rogue) (send, broadcast []*event.Event) {
	d.unoccupy(r)
	return nil, []*event.Event{
		d.newDisplayEvent(r.Pos),
	}
}

// Move moves a rogue from one position to another.
func (d *Dungeon) Move(r *creature.Rogue, data event.MoveData) (send, broadcast []*event.Event) {
	// Ascending or descending is only possible via staircases.
	if data.DLevel != 0 && d.tiles[r.Pos.Level][r.Pos.Y][r.Pos.X].terrain != Staircase {
		return nil, nil
	}

	// Ascending is only possible once the rogue has the Amulet of Yendor.
	if data.DLevel < 0 { // TODO: check if rogue has amulet
		return nil, nil
	}

	originalPos := r.Pos
	newPos := &creature.Position{
		Level: r.Pos.Level + data.DLevel,
		X:     r.Pos.X + data.DX,
		Y:     r.Pos.Y + data.DY,
	}

	if !d.isValid(newPos) {
		return nil, nil
	}

	d.unoccupy(r)
	d.occupy(r, newPos)

	if newPos.Level != originalPos.Level {
		send = []*event.Event{
			d.newLevelEvent(r),
			d.newStatsEvent(r),
		}
	}

	return send, []*event.Event{
		d.newDisplayEvent(originalPos),
		d.newDisplayEvent(r.Pos),
	}
}

// Map returns a string representation of the level.
func (d *Dungeon) Map(r *creature.Rogue) string {
	var m string
	for y := range len(d.tiles[r.Pos.Level]) {
		for x := range len(d.tiles[r.Pos.Level][y]) {
			m += d.tiles[r.Pos.Level][y][x].String()
		}
		m += "\n"
	}
	return m
}

func (d *Dungeon) newDisplayEvent(pos *creature.Position) *event.Event {
	return event.NewEvent(&pos.Level, "display", event.DisplayData{
		X:    pos.X,
		Y:    pos.Y,
		Char: d.tiles[pos.Level][pos.Y][pos.X].String(),
	})
}

func (d *Dungeon) newLevelEvent(r *creature.Rogue) *event.Event {
	return event.NewEvent(nil, "level", event.LevelData{
		Map: d.Map(r),
	})
}

func (d *Dungeon) newStatsEvent(r *creature.Rogue) *event.Event {
	return event.NewEvent(nil, "stats", event.StatsData{
		MapLevel:        r.Pos.Level + 1,
		Gold:            r.Gold,
		HealthPoints:    r.HealthPoints,
		MaxHealthPoints: r.MaxHealthPoints,
		Strength:        r.Strength,
		MaxStrength:     r.MaxStrength,
		ArmourClass:     r.ArmourClass(),
		ExperienceLevel: r.ExperienceLevel,
		Experience:      r.Experience,
	})
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
		x := rand.IntN(len(d.tiles[level][0]))
		y := rand.IntN(len(d.tiles[level]))
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

func (d *Dungeon) isValid(pos *creature.Position) bool {
	if pos.Level < 0 || pos.Level >= len(d.tiles) { // invalid level
		return false
	}
	if pos.Y < 0 || pos.Y >= len(d.tiles[pos.Level]) { // invalid y position
		return false
	}
	if pos.X < 0 || pos.X >= len(d.tiles[pos.Level][pos.Y]) { // invalid x position
		return false
	}
	tile := d.tiles[pos.Level][pos.Y][pos.X].Rune()
	return tile == Floor || tile == Staircase
}
