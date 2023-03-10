package ui

import (
	"fmt"

	tea "github.com/charmbracelet/bubbletea"
)

type GameModel struct {
	name    NameModel
	dungeon *DungeonModel
	err     error
}

func NewGameModel() GameModel {
	return GameModel{name: NewNameModel()}
}

func (m GameModel) Init() tea.Cmd {
	return nil
}

func (m GameModel) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	var cmd tea.Cmd

	switch msg := msg.(type) {
	case error:
		m.err = msg
		return m, nil
	}

	if m.dungeon == nil {
		m.name, cmd = m.name.Update(msg)
		if m.name.value != "" {
			m.dungeon = NewDungeonModel(m.name.value)
		}
	} else {
		m.dungeon, cmd = m.dungeon.Update(msg)
	}

	return m, cmd
}

func (m GameModel) View() string {
	if m.err != nil {
		return fmt.Sprintf("Oh dear -- a mishap!\n\n%s", m.err.Error())
	} else if m.dungeon == nil {
		return m.name.View()
	} else {
		return m.dungeon.View()
	}
}
