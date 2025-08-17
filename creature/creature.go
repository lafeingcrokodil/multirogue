// Package creature contains logic related to creatures that inhabit the dungeon.
package creature

// MaxArmourClass is the maximum (weakest) armour class.
const MaxArmourClass = 10

// Position specifies a position in a dungeon.
type Position struct {
	// Level is the level of the dungeon.
	Level int
	// X is the position on the x axis within the level.
	X int
	// Y is the position on the y axis within the level.
	Y int
}

// Information is information about a living occupant of the dungeons.
type Information struct {
	// Name is the creature's name.
	Name string
	// Symbol is the rune representing the creature.
	Symbol rune
	// Pos is the creature's position in the dungeon.
	Pos *Position
	// DamageDice are rolled to determine how much damage the creature deals.
	DamageDice string
	// ArmourClass is the creature's inherent armour class when not wearing armour.
	ArmourClass int
	// Experience is the amount of experience that the creature has accumulated.
	Experience int
	// ExperienceLevel is the creature's experience level.
	ExperienceLevel int
	// Gold is the amount of gold that the creature currently possesses.
	Gold int
	// HitPoints is the creature's current number of hit points.
	HitPoints int
	// MaxHitPoints is the creature's number of hit points when fully healed.
	MaxHitPoints int
	// Strength is the creature's current strength.
	Strength int
	// MaxStrength is the maximum strength that the creature has attained so far.
	MaxStrength int
}
