package dungeon

import (
	"math/rand"
	"time"

	"github.com/lafeingcrokodil/multirogue/creature"
	"github.com/lafeingcrokodil/multirogue/event"
)

// Creature is a living occupant of the dungeons.
type Creature interface {
	// Position returns the creature's position in the dungeon.
	Position() *creature.Position
	// Rune returns the rune representing the creature.
	Rune() rune
	// SetPosition sets the creature's position in the dungeon.
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
	var tiles [][][]Tile
	for level := 0; level < 21; level++ {
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
	if data.DLevel != 0 && d.tiles[r.Pos.Level][r.Pos.Line][r.Pos.Col].terrain != Staircase {
		return nil, nil
	}

	// Ascending is only possible once the rogue has the Amulet of Yendor.
	if data.DLevel < 0 { // TODO: check if rogue has amulet
		return nil, nil
	}

	originalPos := r.Pos
	newPos := &creature.Position{
		Level: r.Pos.Level + data.DLevel,
		Line:  r.Pos.Line + data.DLine,
		Col:   r.Pos.Col + data.DCol,
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
	for line := 0; line < len(d.tiles[r.Pos.Level]); line++ {
		for col := 0; col < len(d.tiles[r.Pos.Level][line]); col++ {
			m += d.tiles[r.Pos.Level][line][col].String()
		}
		m += "\n"
	}
	return m
}

func (d *Dungeon) newDisplayEvent(pos *creature.Position) *event.Event {
	return event.NewEvent(&pos.Level, "display", event.DisplayData{
		Line: pos.Line,
		Col:  pos.Col,
		Char: d.tiles[pos.Level][pos.Line][pos.Col].String(),
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
		ArmourClass:     4, // TODO: derive armour class from currently-worn armour
		ExperienceLevel: r.ExperienceLevel,
		Experience:      r.Experience,
	})
}

func (d *Dungeon) occupy(c Creature, pos *creature.Position) {
	d.tiles[pos.Level][pos.Line][pos.Col].occupant = c
	c.SetPosition(pos)
}

func (d *Dungeon) unoccupy(c Creature) {
	pos := c.Position()
	d.tiles[pos.Level][pos.Line][pos.Col].occupant = nil
}

func (d *Dungeon) randomSpawnPos(level int) *creature.Position {
	for {
		line := rand.Intn(len(d.tiles[level]))
		col := rand.Intn(len(d.tiles[level][0]))
		if d.isValidSpawnPos(level, line, col) {
			return &creature.Position{
				Level: level,
				Line:  line,
				Col:   col,
			}
		}
	}
}

func (d *Dungeon) isValidSpawnPos(level, line, col int) bool {
	return d.tiles[level][line][col].Rune() == Floor
}

func (d *Dungeon) isValid(pos *creature.Position) bool {
	if pos.Level < 0 || pos.Level >= len(d.tiles) { // invalid level
		return false
	}
	if pos.Line < 0 || pos.Line >= len(d.tiles[pos.Level]) { // invalid y position
		return false
	}
	if pos.Col < 0 || pos.Col >= len(d.tiles[pos.Level][pos.Line]) { // invalid x position
		return false
	}
	tile := d.tiles[pos.Level][pos.Line][pos.Col].Rune()
	return tile == Floor || tile == Staircase
}
