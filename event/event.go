package event

// Event is something that happens in the game, like a player moving.
type Event struct {
	// Level is the dungeon level for which the event is relevant.
	// If it's nil, the event is relevant for all levels.
	Level *int `json:"-"`
	// Name is the name of the event, e.g. "move".
	Name string `json:"name"`
	// Data contains additional information like the direction of movement.
	Data string `json:"data"`
}
