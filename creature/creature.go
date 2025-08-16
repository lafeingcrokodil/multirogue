// Package creature contains logic related to creatures that inhabit the dungeon.
package creature

const maxArmourClass = 10

// Position specifies a position in a dungeon.
type Position struct {
	// Level is the level of the dungeon.
	Level int
	// X is the position on the x axis within the level.
	X int
	// Y is the position on the y axis within the level.
	Y int
}

// Creature is a living occupant of the dungeons.
type Creature struct {
	name            string
	symbol          rune
	pos             *Position
	gold            int
	armourClass     int
	experience      int
	experienceLevel int
	hitPoints       int
	maxHitPoints    int
	strength        int
	maxStrength     int
}

// Name returns the creature's name.
func (c *Creature) Name() string {
	return c.name
}

// Symbol returns the rune representing the creature.
func (c *Creature) Symbol() rune {
	return c.symbol
}

// Position returns the creature's position in the dungeon.
func (c *Creature) Position() *Position {
	return c.pos
}

// SetPosition sets the creature's position in the dungeon.
func (c *Creature) SetPosition(pos *Position) {
	c.pos = pos
}

// Gold returns the number of gold pieces that the creature is carrying.
func (c *Creature) Gold() int {
	return c.gold
}

// ArmourClass returns the creature's current armour class.
func (c *Creature) ArmourClass() int {
	return c.armourClass
}

// Experience returns the number of experience points that the creature has gained so far.
func (c *Creature) Experience() int {
	return c.experience
}

// ExperienceLevel returns the creature's current experience level.
func (c *Creature) ExperienceLevel() int {
	return c.experienceLevel
}

// HitPoints returns the creature's current number of hit points.
func (c *Creature) HitPoints() int {
	return c.hitPoints
}

// MaxHitPoints returns the creature's number of hit points when fully healed.
func (c *Creature) MaxHitPoints() int {
	return c.maxHitPoints
}

// Strength returns the creature's current strength.
func (c *Creature) Strength() int {
	return c.strength
}

// MaxStrength returns the maximum strength that the creature has attained so far.
func (c *Creature) MaxStrength() int {
	return c.maxStrength
}
