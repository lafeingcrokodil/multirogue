package event

import (
	"encoding/json"
	"log"
)

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

// NewEvent creates a new event.
func NewEvent(level *int, name string, d interface{}) *Event {
	data, err := json.Marshal(d)
	if err != nil {
		log.Print("ERROR:", err.Error())
		return nil
	}
	return &Event{
		Level: level,
		Name:  name,
		Data:  string(data),
	}
}

// DisplayData is information related to a "display" event.
type DisplayData struct {
	// X is the position on the x axis.
	X int `json:"x"`
	// Y is the position on the y axis.
	Y int `json:"y"`
	// Char is the character to be displayed.
	Char string `json:"c"`
}

// LevelData is the information related to a "level" event.
type LevelData struct {
	// Map is a string representation of the visible contents of the level.
	Map string `json:"map"`
}

// MoveData is information related to a "move" event.
type MoveData struct {
	// DX is the change in position along the x axis.
	DX int `json:"dx"`
	// DY is the change in position along the y axis.
	DY int `json:"dy"`
}
