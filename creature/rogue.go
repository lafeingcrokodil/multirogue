package creature

import "github.com/lafeingcrokodil/multirogue/random"

// Rogue is an adventurer in a dungeon.
type Rogue struct {
	*Creature
}

// NewRogue creates a new rogue with the specified name.
func NewRogue(name string) *Rogue {
	initialGold := 0
	initialExperience := 0
	initialExperienceLevel := 1
	initialMaxHitPoints := 12
	initialMaxStrength := 16

	return &Rogue{
		Creature: &Creature{
			name:            name,
			symbol:          '@',
			gold:            initialGold,
			armourClass:     maxArmourClass,
			damage:          []*random.Dice{{Count: 1, Sides: 4}}, //nolint:mnd
			experience:      initialExperience,
			experienceLevel: initialExperienceLevel,
			hitPoints:       initialMaxHitPoints,
			maxHitPoints:    initialMaxHitPoints,
			strength:        initialMaxStrength,
			maxStrength:     initialMaxStrength,
		},
	}
}

// ArmourClass returns the rogue's current armour class.
func (r *Rogue) ArmourClass() int {
	return r.armourClass // TODO: derive armour class from currently-worn armour
}
