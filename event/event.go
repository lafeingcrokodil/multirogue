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
	// DLevel is the change in dungeon level.
	DLevel int `json:"dlvl"`
	// DX is the change in position along the x axis.
	DX int `json:"dx"`
	// DY is the change in position along the y axis.
	DY int `json:"dy"`
}

// StatsData describe a rogue's current status.
type StatsData struct {
	// MapLevel is how deep the rogue has gone in the dungeon.
	MapLevel int `json:"mapLvl"`
	// Gold is the number of gold pieces that the rogue has found and kept so far.
	Gold int `json:"gold"`
	// HealthPoints is the rogue's current number of health points.
	HealthPoints int `json:"hp"`
	// MaxHealthPoints is the rogue's number of health points when fully healed.
	MaxHealthPoints int `json:"maxHP"`
	// Strength is the rogue's current strength.
	Strength int `json:"str"`
	// MaxStrength is the maximum strength that the rogue has attained so far.
	MaxStrength int `json:"maxStr"`
	// ArmourClass is the class of the armour that the rogue is currently wearing.
	ArmourClass int `json:"arm"`
	// ExperienceLevel is the rogue's current experience level.
	ExperienceLevel int `json:"lvl"`
	// Experience is the number of experience points that the rogue has gained so far.
	Experience int `json:"exp"`
}
