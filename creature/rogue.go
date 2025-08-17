package creature

// Rogue is an adventurer in a dungeon.
type Rogue struct {
	*Information
}

// NewRogue creates a new rogue with the specified name.
func NewRogue(name string) *Rogue {
	initialMaxHitPoints := 12
	initialMaxStrength := 16

	return &Rogue{
		Information: &Information{
			Name:            name,
			Symbol:          '@',
			DamageDice:      "1d4",
			ArmourClass:     MaxArmourClass,
			ExperienceLevel: 1,
			HitPoints:       initialMaxHitPoints,
			MaxHitPoints:    initialMaxHitPoints,
			Strength:        initialMaxStrength,
			MaxStrength:     initialMaxStrength,
		},
	}
}

// Info returns information about the rogue.
func (r *Rogue) Info() *Information {
	return r.Information
}
