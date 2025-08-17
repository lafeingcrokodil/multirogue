//nolint:mnd
package creature

import (
	"errors"
)

// ErrUnknownMonsterSymbol is thrown if a symbol doesn't represent any known monster.
var ErrUnknownMonsterSymbol = errors.New("unknown monster symbol")

// Monster is a monster in a dungeon.
type Monster struct {
	*Creature

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
			Creature: &Creature{
				name:            "aquator",
				symbol:          symbol,
				armourClass:     2,
				damage:          "0d0+0d0",
				experienceLevel: 5,
			},
			difficulty: 20,
			isMean:     true,
		}, nil
	case 'B':
		return &Monster{
			Creature: &Creature{
				name:            "bat",
				symbol:          symbol,
				armourClass:     3,
				damage:          "1d2",
				experienceLevel: 1,
			},
			difficulty: 1,
			isFly:      true,
		}, nil
	case 'C':
		return &Monster{
			Creature: &Creature{
				name:            "centaur",
				symbol:          symbol,
				armourClass:     4,
				damage:          "1d2+1d5+1d5",
				experienceLevel: 4,
			},
			difficulty:      17,
			lootProbability: 15,
		}, nil
	case 'D':
		return &Monster{
			Creature: &Creature{
				name:            "dragon",
				symbol:          symbol,
				armourClass:     -1,
				damage:          "1d8+1d8+3d10",
				experienceLevel: 10,
			},
			difficulty:      5000,
			lootProbability: 100,
			isMean:          true,
		}, nil
	case 'E':
		return &Monster{
			Creature: &Creature{
				name:            "emu",
				symbol:          symbol,
				armourClass:     7,
				damage:          "1d2",
				experienceLevel: 1,
			},
			difficulty: 2,
			isMean:     true,
		}, nil
	case 'F':
		return &Monster{
			Creature: &Creature{
				name:            "venus flytrap",
				symbol:          symbol,
				armourClass:     3,
				experienceLevel: 8,
			},
			difficulty: 80,
			isMean:     true,
		}, nil
	case 'G':
		return &Monster{
			Creature: &Creature{
				name:            "griffin",
				symbol:          symbol,
				armourClass:     2,
				damage:          "4d3+3d5",
				experienceLevel: 13,
			},
			difficulty:      2000,
			lootProbability: 20,
			isFly:           true,
			isMean:          true,
			isRegen:         true,
		}, nil
	case 'H':
		return &Monster{
			Creature: &Creature{
				name:            "hobgoblin",
				symbol:          symbol,
				armourClass:     5,
				damage:          "1d8",
				experienceLevel: 1,
			},
			difficulty: 3,
			isMean:     true,
		}, nil
	case 'I':
		return &Monster{
			Creature: &Creature{
				name:            "ice monster",
				symbol:          symbol,
				armourClass:     9,
				damage:          "0d0",
				experienceLevel: 1,
			},
			difficulty: 5,
		}, nil
	case 'J':
		return &Monster{
			Creature: &Creature{
				name:            "jabberwock",
				symbol:          symbol,
				armourClass:     6,
				damage:          "2d12+2d4",
				experienceLevel: 15,
			},
			difficulty:      3000,
			lootProbability: 70,
		}, nil
	case 'K':
		return &Monster{
			Creature: &Creature{
				name:            "kestrel",
				symbol:          symbol,
				armourClass:     7,
				damage:          "1d4",
				experienceLevel: 1,
			},
			difficulty: 1,
			isFly:      true,
			isMean:     true,
		}, nil
	case 'L':
		return &Monster{
			Creature: &Creature{
				name:            "leprechaun",
				symbol:          symbol,
				armourClass:     8,
				damage:          "1d1",
				experienceLevel: 3,
			},
			difficulty: 10,
		}, nil
	case 'M':
		return &Monster{
			Creature: &Creature{
				name:            "medusa",
				symbol:          symbol,
				armourClass:     2,
				damage:          "3d4+3d4+2d5",
				experienceLevel: 8,
			},
			difficulty:      200,
			lootProbability: 40,
			isMean:          true,
		}, nil
	case 'N':
		return &Monster{
			Creature: &Creature{
				name:            "emu",
				symbol:          symbol,
				armourClass:     9,
				damage:          "0d0",
				experienceLevel: 3,
			},
			difficulty:      37,
			lootProbability: 100,
		}, nil
	case 'O':
		return &Monster{
			Creature: &Creature{
				name:            "orc",
				symbol:          symbol,
				armourClass:     6,
				damage:          "1d8",
				experienceLevel: 1,
			},
			difficulty:      5,
			lootProbability: 15,
			isGreed:         true,
		}, nil
	case 'P':
		return &Monster{
			Creature: &Creature{
				name:            "phantom",
				symbol:          symbol,
				armourClass:     3,
				damage:          "4d4",
				experienceLevel: 8,
			},
			difficulty:  120,
			isInvisible: true,
		}, nil
	case 'Q':
		return &Monster{
			Creature: &Creature{
				name:            "quagga",
				symbol:          symbol,
				armourClass:     3,
				damage:          "1d5+1d5",
				experienceLevel: 3,
			},
			difficulty: 15,
			isMean:     true,
		}, nil
	case 'R':
		return &Monster{
			Creature: &Creature{
				name:            "rattlesnake",
				symbol:          symbol,
				armourClass:     3,
				damage:          "1d6",
				experienceLevel: 2,
			},
			difficulty: 9,
			isMean:     true,
		}, nil
	case 'S':
		return &Monster{
			Creature: &Creature{
				name:            "snake",
				symbol:          symbol,
				armourClass:     5,
				damage:          "1d3",
				experienceLevel: 1,
			},
			difficulty: 2,
			isMean:     true,
		}, nil
	case 'T':
		return &Monster{
			Creature: &Creature{
				name:            "troll",
				symbol:          symbol,
				armourClass:     4,
				damage:          "1d8+1d8+2d6",
				experienceLevel: 6,
			},
			difficulty:      120,
			lootProbability: 50,
			isMean:          true,
			isRegen:         true,
		}, nil
	case 'U':
		return &Monster{
			Creature: &Creature{
				name:            "black unicorn",
				symbol:          symbol,
				armourClass:     -2,
				damage:          "1d9+1d9+2d9",
				experienceLevel: 7,
			},
			difficulty: 190,
			isMean:     true,
		}, nil
	case 'V':
		return &Monster{
			Creature: &Creature{
				name:            "vampire",
				symbol:          symbol,
				armourClass:     1,
				damage:          "1d10",
				experienceLevel: 8,
			},
			difficulty:      350,
			lootProbability: 20,
			isMean:          true,
			isRegen:         true,
		}, nil
	case 'W':
		return &Monster{
			Creature: &Creature{
				name:            "wraith",
				symbol:          symbol,
				armourClass:     4,
				damage:          "1d6",
				experienceLevel: 5,
			},
			difficulty: 55,
		}, nil
	case 'X':
		return &Monster{
			Creature: &Creature{
				name:            "xeroc",
				symbol:          symbol,
				armourClass:     7,
				damage:          "4d4",
				experienceLevel: 7,
			},
			difficulty:      100,
			lootProbability: 30,
		}, nil
	case 'Y':
		return &Monster{
			Creature: &Creature{
				name:            "yeti",
				symbol:          symbol,
				armourClass:     6,
				damage:          "1d6+1d6",
				experienceLevel: 4,
			},
			difficulty:      50,
			lootProbability: 30,
		}, nil
	case 'Z':
		return &Monster{
			Creature: &Creature{
				name:            "zombie",
				symbol:          symbol,
				armourClass:     8,
				damage:          "1d8",
				experienceLevel: 2,
			},
			difficulty: 6,
			isMean:     true,
		}, nil
	default:
		return nil, ErrUnknownMonsterSymbol
	}
}
