package creature

// Rogue is an adventurer in a dungeon.
type Rogue struct {
	// Name is the rogue's name.
	Name string
	// Pos is the rogues position in the dungeon.
	Pos *Position
	// Gold is the number of gold pieces that the rogue has found and kept so far.
	Gold int
	// HealthPoints is the rogue's current number of health points.
	HealthPoints int
	// MaxHealthPoints is the rogue's number of health points when fully healed.
	MaxHealthPoints int
	// Strength is the rogue's current strength.
	Strength int
	// MaxStrength is the maximum strength that the rogue has attained so far.
	MaxStrength int
	// ExperienceLevel is the rogue's current experience level.
	ExperienceLevel int
	// Experience is the number of experience points that the rogue has gained so far.
	Experience int
}

// NewRogue creates a new rogue with the specified name.
func NewRogue(name string) *Rogue {
	return &Rogue{
		Name:            name,
		HealthPoints:    12,
		MaxHealthPoints: 12,
		Strength:        16,
		MaxStrength:     16,
		ExperienceLevel: 1,
	}
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
