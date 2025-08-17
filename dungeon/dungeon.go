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
	// Info returns information about the creature.
	Info() *creature.Information
}

// Dungeon is a randomly generated set of rooms, passages, monsters and
// items spread over multiple levels.
type Dungeon struct {
	tiles [][][]Tile
}

// New just generates a dungeon with blank levels for now.
func New() *Dungeon {
	tiles := make([][][]Tile, 0, numLevels)
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
			d.newDisplayEvent(r.Info().Pos),
			d.newNotificationEvent(r.Info().Name + " has entered the dungeon."),
		}
}

// Remove removes a rogue from a dungeon.
func (d *Dungeon) Remove(r *creature.Rogue) (send, broadcast []*event.Event) {
	d.unoccupy(r)
	return nil, []*event.Event{
		d.newDisplayEvent(r.Info().Pos),
		d.newNotificationEvent(r.Info().Name + " has left the dungeon."),
	}
}

// Move moves a rogue from one position to another.
func (d *Dungeon) Move(r *creature.Rogue, data event.MoveData) (send, broadcast []*event.Event) {
	// Ascending or descending is only possible via staircases.
	if data.DLevel != 0 && d.tiles[r.Info().Pos.Level][r.Info().Pos.Y][r.Info().Pos.X].terrain != Staircase {
		return nil, nil
	}

	// Ascending is only possible once the rogue has the Amulet of Yendor.
	if data.DLevel < 0 { // TODO: check if rogue has amulet
		return nil, nil
	}

	originalPos := r.Info().Pos
	newPos := &creature.Position{
		Level: r.Info().Pos.Level + data.DLevel,
		X:     r.Info().Pos.X + data.DX,
		Y:     r.Info().Pos.Y + data.DY,
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
		d.newDisplayEvent(r.Info().Pos),
	}
}

// Map returns a string representation of the level.
func (d *Dungeon) Map(r *creature.Rogue) string {
	var m string
	for y := range len(d.tiles[r.Info().Pos.Level]) {
		for x := range len(d.tiles[r.Info().Pos.Level][y]) {
			m += d.tiles[r.Info().Pos.Level][y][x].String()
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

func (d *Dungeon) newNotificationEvent(msg string) *event.Event {
	return event.NewEvent(nil, "notification", event.NotificationData{
		Message: msg,
	})
}

func (d *Dungeon) newStatsEvent(r *creature.Rogue) *event.Event {
	return event.NewEvent(nil, "stats", event.StatsData{
		MapLevel:        r.Info().Pos.Level + 1,
		Gold:            r.Info().Gold,
		HitPoints:       r.Info().HitPoints,
		MaxHitPoints:    r.Info().MaxHitPoints,
		Strength:        r.Info().Strength,
		MaxStrength:     r.Info().MaxStrength,
		ArmourClass:     creature.MaxArmourClass - r.Info().ArmourClass,
		ExperienceLevel: r.Info().ExperienceLevel,
		Experience:      r.Info().Experience,
	})
}

func (d *Dungeon) occupy(c Creature, pos *creature.Position) {
	d.tiles[pos.Level][pos.Y][pos.X].occupant = c
	c.Info().Pos = pos
}

func (d *Dungeon) unoccupy(c Creature) {
	pos := c.Info().Pos
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
	return d.tiles[level][y][x].Symbol() == Floor
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
	tile := d.tiles[pos.Level][pos.Y][pos.X].Symbol()
	return tile == Floor || tile == Staircase
}
