package ui

import (
	"fmt"

	"github.com/charmbracelet/bubbles/help"
	"github.com/charmbracelet/bubbles/key"
	"github.com/charmbracelet/bubbles/textinput"
	tea "github.com/charmbracelet/bubbletea"
)

type NameModel struct {
	help   help.Model
	input  textinput.Model
	value  string
	submit key.Binding
	quit   key.Binding
}

func NewNameModel() NameModel {
	m := NameModel{
		help:  help.New(),
		input: textinput.New(),
		submit: key.NewBinding(
			key.WithKeys(tea.KeyEnter.String()),
			key.WithHelp("ENTER", "submit"),
		),
		quit: key.NewBinding(
			key.WithKeys(tea.KeyEsc.String(), tea.KeyCtrlC.String()),
			key.WithHelp("ESC", "quit"),
		),
	}

	m.input.Placeholder = "Nemo"
	m.input.Focus()
	m.input.CharLimit = 20
	m.input.Width = 20

	m.submit.SetEnabled(false)

	return m
}

func (m NameModel) Init() tea.Cmd {
	return textinput.Blink
}

func (m NameModel) Update(msg tea.Msg) (NameModel, tea.Cmd) {
	var cmd tea.Cmd

	switch msg := msg.(type) {
	case tea.KeyMsg:
		switch {
		case key.Matches(msg, m.submit):
			m.value = m.input.Value()
			return m, nil
		case key.Matches(msg, m.quit):
			return m, tea.Quit
		}
	}

	m.input, cmd = m.input.Update(msg)
	if m.input.Value() != "" {
		m.submit.SetEnabled(true)
	}

	return m, cmd
}

func (m NameModel) View() string {
	return fmt.Sprintf(
		"Welcome to the Dungeons of Doom! What is your name?\n\n%s\n\n%s\n",
		m.input.View(),
		m.help.ShortHelpView([]key.Binding{m.submit, m.quit}),
	)
}
