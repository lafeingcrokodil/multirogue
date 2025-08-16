package creature

const (
	initialMaxHealthPoints = 12
	initialMaxStrength     = 16
	initialExperienceLevel = 1

	// We're hardcoding the armour class for now, but we can get rid of this
	// after implementing logic for deriving the armour class from the armour
	// being worn by the rogue.
	armourClass = 4
)

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
		HealthPoints:    initialMaxHealthPoints,
		MaxHealthPoints: initialMaxHealthPoints,
		Strength:        initialMaxStrength,
		MaxStrength:     initialMaxStrength,
		ExperienceLevel: initialExperienceLevel,
	}
}

// ArmourClass returns the rogue's current armour class.
func (r *Rogue) ArmourClass() int {
	return armourClass // TODO: derive armour class from currently-worn armour
}

// Position returns the rogue's current position.
func (r *Rogue) Position() *Position {
	return r.Pos
}

// Rune returns the rune representing the rogue.
func (r *Rogue) Rune() rune {
	return '@'
}

// SetPosition moves the rogue to the specified position.
func (r *Rogue) SetPosition(pos *Position) {
	r.Pos = pos
}
