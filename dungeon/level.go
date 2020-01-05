package dungeon

// Level is one of the levels in a dungeon.
type Level struct {
	tiles [][]Tile
}

// newLevel just generates a blank level for now.
func newLevel() *Level {
	var ts [][]Tile
	for y := 0; y < 24; y++ {
		var t []Tile
		for x := 0; x < 80; x++ {
			t = append(t, Tile{x: x, y: y, terrain: Floor})
		}
		ts = append(ts, t)
	}
	return &Level{tiles: ts}
}

// Map returns a string representation of the level.
func (l *Level) Map() string {
	var m string
	for y := 0; y < len(l.tiles); y++ {
		for x := 0; x < len(l.tiles[y]); x++ {
			m += string(l.tiles[y][x].Rune())
		}
		m += "\\n"
	}
	return m
}
