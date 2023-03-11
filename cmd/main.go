package main

import (
	"log"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/lafeingcrokodil/multirogue/ui"
)

func main() {
	f, err := tea.LogToFile("debug.log", "debug")
	if err != nil {
		log.Fatal(err)
	}
	defer f.Close()

	p := tea.NewProgram(ui.NewGameModel(), tea.WithAltScreen())
	if _, err := p.Run(); err != nil {
		log.Fatal(err)
	}
}
