package ui

import (
	"fmt"

	"github.com/charmbracelet/bubbles/help"
	"github.com/charmbracelet/bubbles/key"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/lafeingcrokodil/multirogue/dungeon"
)

type DungeonModel struct {
	dungeon *dungeon.Dungeon
	help    help.Model
	keymap  Keymap
	stats   StatModel
}

func NewDungeonModel(rogueName string) *DungeonModel {
	return &DungeonModel{
		dungeon: dungeon.NewDungeon(rogueName),
		help:    help.New(),
		keymap:  NewKeymap(),
	}
}

func (m *DungeonModel) Init() tea.Cmd {
	return nil
}

func (m *DungeonModel) Update(msg tea.Msg) (*DungeonModel, tea.Cmd) {
	var cmd tea.Cmd

	switch msg := msg.(type) {
	case tea.KeyMsg:
		switch {
		case key.Matches(msg, m.keymap.Help):
			m.help.ShowAll = !m.help.ShowAll
		case key.Matches(msg, m.keymap.Quit):
			return m, tea.Quit
		case key.Matches(msg, m.keymap.Left):
			m.dungeon.MoveRogue(0, 0, -1)
		case key.Matches(msg, m.keymap.Down):
			m.dungeon.MoveRogue(0, 1, 0)
		case key.Matches(msg, m.keymap.Up):
			m.dungeon.MoveRogue(0, -1, 0)
		case key.Matches(msg, m.keymap.Right):
			m.dungeon.MoveRogue(0, 0, 1)
		case key.Matches(msg, m.keymap.UpLeft):
			m.dungeon.MoveRogue(0, -1, -1)
		case key.Matches(msg, m.keymap.UpRight):
			m.dungeon.MoveRogue(0, -1, 1)
		case key.Matches(msg, m.keymap.DownLeft):
			m.dungeon.MoveRogue(0, 1, -1)
		case key.Matches(msg, m.keymap.DownRight):
			m.dungeon.MoveRogue(0, 1, 1)
		}
	}

	m.stats, cmd = m.stats.Update(msg)

	return m, cmd
}

func (m *DungeonModel) View() string {
	var level string
	for _, line := range m.dungeon.CurrentLevel().Tiles {
		for _, t := range line {
			level += string(t.Rune())
		}
		level += "\n"
	}
	return fmt.Sprintf(
		"%s%s\n\n%s\n",
		level,
		m.stats.View(),
		m.help.View(m.keymap),
	)
}
