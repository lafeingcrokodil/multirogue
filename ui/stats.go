package ui

import (
	tea "github.com/charmbracelet/bubbletea"
)

type StatModel struct{}

func (m StatModel) Init() tea.Cmd {
	return nil
}

func (m StatModel) Update(msg tea.Msg) (StatModel, tea.Cmd) {
	return m, nil
}

func (m StatModel) View() string {
	return "Level: 1  Gold: 0      Hp: 12(12)   Str: 16(16) Arm: 4  Exp: 1/0"
}
