//nolint:mnd
package creature

import (
	"errors"
)

// ErrUnknownMonsterSymbol is thrown if a symbol doesn't represent any known monster.
var ErrUnknownMonsterSymbol = errors.New("unknown monster symbol")

// Monster is a monster in a dungeon.
type Monster struct {
	*Information

	difficulty      int
	lootProbability int

	isFly       bool
	isGreed     bool
	isInvisible bool
	isMean      bool
	isRegen     bool
}

// NewMonster returns a new monster represented by the specified rune.
func NewMonster(symbol rune) (*Monster, error) {
	switch symbol {
	case 'A':
		return &Monster{
			Information: &Information{
				Name:            "aquator",
				Symbol:          symbol,
				ArmourClass:     2,
				DamageDice:      "0d0+0d0",
				ExperienceLevel: 5,
			},
			difficulty: 20,
			isMean:     true,
		}, nil
	case 'B':
		return &Monster{
			Information: &Information{
				Name:            "bat",
				Symbol:          symbol,
				ArmourClass:     3,
				DamageDice:      "1d2",
				ExperienceLevel: 1,
			},
			difficulty: 1,
			isFly:      true,
		}, nil
	case 'C':
		return &Monster{
			Information: &Information{
				Name:            "centaur",
				Symbol:          symbol,
				ArmourClass:     4,
				DamageDice:      "1d2+1d5+1d5",
				ExperienceLevel: 4,
			},
			difficulty:      17,
			lootProbability: 15,
		}, nil
	case 'D':
		return &Monster{
			Information: &Information{
				Name:            "dragon",
				Symbol:          symbol,
				ArmourClass:     -1,
				DamageDice:      "1d8+1d8+3d10",
				ExperienceLevel: 10,
			},
			difficulty:      5000,
			lootProbability: 100,
			isMean:          true,
		}, nil
	case 'E':
		return &Monster{
			Information: &Information{
				Name:            "emu",
				Symbol:          symbol,
				ArmourClass:     7,
				DamageDice:      "1d2",
				ExperienceLevel: 1,
			},
			difficulty: 2,
			isMean:     true,
		}, nil
	case 'F':
		return &Monster{
			Information: &Information{
				Name:            "venus flytrap",
				Symbol:          symbol,
				ArmourClass:     3,
				ExperienceLevel: 8,
			},
			difficulty: 80,
			isMean:     true,
		}, nil
	case 'G':
		return &Monster{
			Information: &Information{
				Name:            "griffin",
				Symbol:          symbol,
				ArmourClass:     2,
				DamageDice:      "4d3+3d5",
				ExperienceLevel: 13,
			},
			difficulty:      2000,
			lootProbability: 20,
			isFly:           true,
			isMean:          true,
			isRegen:         true,
		}, nil
	case 'H':
		return &Monster{
			Information: &Information{
				Name:            "hobgoblin",
				Symbol:          symbol,
				ArmourClass:     5,
				DamageDice:      "1d8",
				ExperienceLevel: 1,
			},
			difficulty: 3,
			isMean:     true,
		}, nil
	case 'I':
		return &Monster{
			Information: &Information{
				Name:            "ice monster",
				Symbol:          symbol,
				ArmourClass:     9,
				DamageDice:      "0d0",
				ExperienceLevel: 1,
			},
			difficulty: 5,
		}, nil
	case 'J':
		return &Monster{
			Information: &Information{
				Name:            "jabberwock",
				Symbol:          symbol,
				ArmourClass:     6,
				DamageDice:      "2d12+2d4",
				ExperienceLevel: 15,
			},
			difficulty:      3000,
			lootProbability: 70,
		}, nil
	case 'K':
		return &Monster{
			Information: &Information{
				Name:            "kestrel",
				Symbol:          symbol,
				ArmourClass:     7,
				DamageDice:      "1d4",
				ExperienceLevel: 1,
			},
			difficulty: 1,
			isFly:      true,
			isMean:     true,
		}, nil
	case 'L':
		return &Monster{
			Information: &Information{
				Name:            "leprechaun",
				Symbol:          symbol,
				ArmourClass:     8,
				DamageDice:      "1d1",
				ExperienceLevel: 3,
			},
			difficulty: 10,
		}, nil
	case 'M':
		return &Monster{
			Information: &Information{
				Name:            "medusa",
				Symbol:          symbol,
				ArmourClass:     2,
				DamageDice:      "3d4+3d4+2d5",
				ExperienceLevel: 8,
			},
			difficulty:      200,
			lootProbability: 40,
			isMean:          true,
		}, nil
	case 'N':
		return &Monster{
			Information: &Information{
				Name:            "emu",
				Symbol:          symbol,
				ArmourClass:     9,
				DamageDice:      "0d0",
				ExperienceLevel: 3,
			},
			difficulty:      37,
			lootProbability: 100,
		}, nil
	case 'O':
		return &Monster{
			Information: &Information{
				Name:            "orc",
				Symbol:          symbol,
				ArmourClass:     6,
				DamageDice:      "1d8",
				ExperienceLevel: 1,
			},
			difficulty:      5,
			lootProbability: 15,
			isGreed:         true,
		}, nil
	case 'P':
		return &Monster{
			Information: &Information{
				Name:            "phantom",
				Symbol:          symbol,
				ArmourClass:     3,
				DamageDice:      "4d4",
				ExperienceLevel: 8,
			},
			difficulty:  120,
			isInvisible: true,
		}, nil
	case 'Q':
		return &Monster{
			Information: &Information{
				Name:            "quagga",
				Symbol:          symbol,
				ArmourClass:     3,
				DamageDice:      "1d5+1d5",
				ExperienceLevel: 3,
			},
			difficulty: 15,
			isMean:     true,
		}, nil
	case 'R':
		return &Monster{
			Information: &Information{
				Name:            "rattlesnake",
				Symbol:          symbol,
				ArmourClass:     3,
				DamageDice:      "1d6",
				ExperienceLevel: 2,
			},
			difficulty: 9,
			isMean:     true,
		}, nil
	case 'S':
		return &Monster{
			Information: &Information{
				Name:            "snake",
				Symbol:          symbol,
				ArmourClass:     5,
				DamageDice:      "1d3",
				ExperienceLevel: 1,
			},
			difficulty: 2,
			isMean:     true,
		}, nil
	case 'T':
		return &Monster{
			Information: &Information{
				Name:            "troll",
				Symbol:          symbol,
				ArmourClass:     4,
				DamageDice:      "1d8+1d8+2d6",
				ExperienceLevel: 6,
			},
			difficulty:      120,
			lootProbability: 50,
			isMean:          true,
			isRegen:         true,
		}, nil
	case 'U':
		return &Monster{
			Information: &Information{
				Name:            "black unicorn",
				Symbol:          symbol,
				ArmourClass:     -2,
				DamageDice:      "1d9+1d9+2d9",
				ExperienceLevel: 7,
			},
			difficulty: 190,
			isMean:     true,
		}, nil
	case 'V':
		return &Monster{
			Information: &Information{
				Name:            "vampire",
				Symbol:          symbol,
				ArmourClass:     1,
				DamageDice:      "1d10",
				ExperienceLevel: 8,
			},
			difficulty:      350,
			lootProbability: 20,
			isMean:          true,
			isRegen:         true,
		}, nil
	case 'W':
		return &Monster{
			Information: &Information{
				Name:            "wraith",
				Symbol:          symbol,
				ArmourClass:     4,
				DamageDice:      "1d6",
				ExperienceLevel: 5,
			},
			difficulty: 55,
		}, nil
	case 'X':
		return &Monster{
			Information: &Information{
				Name:            "xeroc",
				Symbol:          symbol,
				ArmourClass:     7,
				DamageDice:      "4d4",
				ExperienceLevel: 7,
			},
			difficulty:      100,
			lootProbability: 30,
		}, nil
	case 'Y':
		return &Monster{
			Information: &Information{
				Name:            "yeti",
				Symbol:          symbol,
				ArmourClass:     6,
				DamageDice:      "1d6+1d6",
				ExperienceLevel: 4,
			},
			difficulty:      50,
			lootProbability: 30,
		}, nil
	case 'Z':
		return &Monster{
			Information: &Information{
				Name:            "zombie",
				Symbol:          symbol,
				ArmourClass:     8,
				DamageDice:      "1d8",
				ExperienceLevel: 2,
			},
			difficulty: 6,
			isMean:     true,
		}, nil
	default:
		return nil, ErrUnknownMonsterSymbol
	}
}

// Info returns information about the monster.
func (m *Monster) Info() *Information {
	return m.Information
}
