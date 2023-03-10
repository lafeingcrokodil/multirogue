package ui

import (
	"github.com/charmbracelet/bubbles/key"
	tea "github.com/charmbracelet/bubbletea"
)

type Keymap struct {
	Help      key.Binding
	Left      key.Binding
	Down      key.Binding
	Up        key.Binding
	Right     key.Binding
	UpLeft    key.Binding
	UpRight   key.Binding
	DownLeft  key.Binding
	DownRight key.Binding
	Submit    key.Binding
	Quit      key.Binding
}

func NewKeymap() Keymap {
	return Keymap{
		Help: key.NewBinding(
			key.WithKeys("?"),
			key.WithHelp("?", "toggle help"),
		),
		Left: key.NewBinding(
			key.WithKeys("h"),
			key.WithHelp("h", "move left"),
		),
		Down: key.NewBinding(
			key.WithKeys("j"),
			key.WithHelp("j", "move down"),
		),
		Up: key.NewBinding(
			key.WithKeys("k"),
			key.WithHelp("k", "move up"),
		),
		Right: key.NewBinding(
			key.WithKeys("l"),
			key.WithHelp("l", "move right"),
		),
		UpLeft: key.NewBinding(
			key.WithKeys("y"),
			key.WithHelp("y", "move up and left"),
		),
		UpRight: key.NewBinding(
			key.WithKeys("u"),
			key.WithHelp("u", "move up and right"),
		),
		DownLeft: key.NewBinding(
			key.WithKeys("b"),
			key.WithHelp("b", "move down and left"),
		),
		DownRight: key.NewBinding(
			key.WithKeys("n"),
			key.WithHelp("n", "move down and right"),
		),
		Quit: key.NewBinding(
			key.WithKeys(tea.KeyEsc.String(), tea.KeyCtrlC.String()),
			key.WithHelp("ESC", "quit"),
		),
	}
}

func (k Keymap) ShortHelp() []key.Binding {
	return []key.Binding{k.Help, k.Quit}
}

func (k Keymap) FullHelp() [][]key.Binding {
	return [][]key.Binding{
		{k.Left, k.Down, k.Up, k.Right},
		{k.UpLeft, k.UpRight, k.DownLeft, k.DownRight},
		{k.Help, k.Quit},
	}
}
