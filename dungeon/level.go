package dungeon

import (
	"fmt"
	"math/rand"
	"time"
)

type Direction string

const (
	North Direction = "NORTH"
	East  Direction = "EAST"
	South Direction = "SOUTH"
	West  Direction = "WEST"
)

type Bounds struct {
	min Tile
	max Tile
}

type Quadrant struct {
	id       int
	room     *Bounds
	fixPoint *Tile
}

type Edge struct {
	src int
	dst int
}

type Generator struct {
	adjacencies map[int]map[int]Direction
	opposites   map[Direction]Direction
}

func NewGenerator() *Generator {
	rand.Seed(time.Now().UnixNano())
	return &Generator{
		adjacencies: map[int]map[int]Direction{
			0: {1: East, 3: South},
			1: {0: West, 2: East, 4: South},
			2: {1: West, 5: South},
			3: {0: North, 4: East, 6: South},
			4: {1: North, 3: West, 5: East, 7: South},
			5: {2: North, 4: West, 8: South},
			6: {3: North, 7: East},
			7: {4: North, 6: West, 8: East},
			8: {5: North, 7: West},
		},
		opposites: map[Direction]Direction{
			North: South,
			South: North,
			East:  West,
			West:  East,
		},
	}
}

// NewLevel randomly generates a new dungeon level, including rooms, passages,
// doors, and a staircase.
func (g *Generator) NewLevel() [][]*Tile {
	qs := make([]Quadrant, 9)
	// Determine how many of the nine quadrants will contain a room.
	numRooms := randInt(6, 9)
	// Permute the quadrants to help randomly select which will contain rooms.
	quadrantIDs := rand.Perm(9)
	for i, id := range quadrantIDs {
		qs[id] = Quadrant{id: id}
		qb := quadrantBounds(id)
		// For example, if numRooms is 7, then the first 7 permuted quadrants will have a room.
		if i < numRooms {
			rb := roomBounds(qb)
			qs[id].room = &rb
		} else {
			fp := fixPoint(qb)
			qs[id].fixPoint = &fp
		}
	}
	return tiles(qs, g.passages(qs), staircase(qs))
}

// quadrantBounds calculates the bounds of a given quadrant.
func quadrantBounds(id int) Bounds {
	return Bounds{
		min: Tile{
			x: (id % 3) * (MaxX / 3),
			y: (id/3)*(MaxY/3) + 1,
		},
		max: Tile{
			x: (id%3+1)*(MaxX/3) - 2,
			y: (id/3+1)*(MaxY/3) - 1,
		},
	}
}

// roomBounds randomly chooses the bounds of a room within a quadrant.
func roomBounds(qb Bounds) Bounds {
	topLeft := Tile{
		x: randInt(qb.min.x, qb.max.x-4),
		y: randInt(qb.min.y, qb.max.y-4),
	}
	return Bounds{
		min: topLeft,
		max: Tile{
			x: randInt(topLeft.x+4, qb.max.x),
			y: randInt(topLeft.y+4, qb.max.y),
		},
	}
}

// fixPoint randomly chooses a point within a quadrant.
func fixPoint(qb Bounds) Tile {
	return Tile{
		x:       randInt(qb.min.x+1, qb.max.x-1),
		y:       randInt(qb.min.y+1, qb.max.y-1),
		terrain: Passage,
	}
}

// passages generates passages to connect the specified quadrants.
func (g *Generator) passages(qs []Quadrant) [][]Tile {
	es := g.edges()
	ps := make([][]Tile, 0, len(es))
	for _, e := range es {
		dir := g.adjacencies[e.src][e.dst]
		p := make([]Tile, 6)

		// Determine starting point of passage.
		if r := qs[e.src].room; r != nil {
			p[0] = door(r, dir)
		} else {
			p[0] = *qs[e.src].fixPoint
		}

		// Determine endpoint of passage.
		if r := qs[e.dst].room; r != nil {
			p[5] = door(r, g.opposites[dir])
		} else {
			p[5] = *qs[e.dst].fixPoint
		}

		// Take a step toward the center of the passage from either end.
		switch dir {
		case North:
			p[1] = Tile{x: p[0].x, y: p[0].y - 1, terrain: Passage}
			p[4] = Tile{x: p[5].x, y: p[5].y + 1, terrain: Passage}
		case South:
			p[1] = Tile{x: p[0].x, y: p[0].y + 1, terrain: Passage}
			p[4] = Tile{x: p[5].x, y: p[5].y - 1, terrain: Passage}
		case East:
			p[1] = Tile{x: p[0].x + 1, y: p[0].y, terrain: Passage}
			p[4] = Tile{x: p[5].x - 1, y: p[5].y, terrain: Passage}
		case West:
			p[1] = Tile{x: p[0].x - 1, y: p[0].y, terrain: Passage}
			p[4] = Tile{x: p[5].x + 1, y: p[5].y, terrain: Passage}
		}

		// Fill in the remaining tiles.
		if rand.Intn(2) < 1 {
			minX := minInt(p[0].x, p[5].x)
			maxX := maxInt(p[0].x, p[5].x)
			fmt.Printf("%#v -> %#v\n", p[0], p[5])
			fmt.Printf("minX: %d, maxX: %d\n", minX, maxX)
			p[2] = Tile{x: randInt(minX, maxX), y: p[1].y, terrain: Passage}
			p[3] = Tile{x: p[2].x, y: p[4].y, terrain: Passage}
		} else {
			minY := minInt(p[0].y, p[5].y)
			maxY := maxInt(p[0].y, p[5].y)
			fmt.Printf("%#v -> %#v\n", p[0], p[5])
			fmt.Printf("minY: %d, maxY: %d\n", minY, maxY)
			p[2] = Tile{x: p[1].x, y: randInt(minY, maxY), terrain: Passage}
			p[3] = Tile{x: p[4].x, y: p[2].y, terrain: Passage}
		}

		ps = append(ps, p)
	}
	return ps
}

// edges randomly determines which quadrants will be connected by passages.
func (g *Generator) edges() []Edge {
	var es, pool []Edge

	// We start in the top left quadrant (0). We need to add edges to connect all
	// of the other quadrants.
	remaining := []int{1, 2, 3, 4, 5, 6, 7, 8}

	// Initialize the pool of possible edges with edges that connect the top left
	// quadrant with adjacent quadrants.
	for id := range g.adjacencies[0] {
		pool = append(pool, Edge{src: 0, dst: id})
	}

	// Add enough edges to connect all quadrants.
	for len(remaining) > 0 {
		// Randomly pick an edge from the pool of possible edges.
		i := rand.Intn(len(pool))
		e := pool[i]
		es = append(es, e)
		// The e.dst quadrant is now connected.
		remaining = filterInts(remaining, func(i int) bool { return i != e.dst })
		// Since the quadrant is already connected, we're no longer interested in
		// edges that lead to it.
		pool = filterEdges(pool, func(x Edge) bool { return x.dst != e.dst })
		// We are, however, interested in edges that lead from it to quadrants that
		// aren't yet connected. We'll add those to our pool of edges.
		for adj := range g.adjacencies[e.dst] {
			for _, id := range remaining {
				if adj == id {
					pool = append(pool, Edge{src: e.dst, dst: adj})
				}
			}
		}
	}

	// Randomly add some more edges, so that there are more options when trying
	// to get from one point to another.
	for id := 0; id < 9; id++ {
		for adj := range g.adjacencies[id] {
			if id >= adj { // avoid considering the same edge twice
				continue
			}
			e := Edge{src: id, dst: adj}
			missing := true
			for _, x := range es {
				// check if the edges are the same, regardless of direction
				if e.src == x.src && e.dst == x.dst || e.src == x.dst && e.dst == x.src {
					missing = false
					break
				}
			}
			if missing && rand.Intn(5) < 2 {
				es = append(es, e)
			}
		}
	}

	return es
}

func filterEdges(es []Edge, fn func(Edge) bool) []Edge {
	var filtered []Edge
	for _, e := range es {
		if fn(e) {
			filtered = append(filtered, e)
		}
	}
	return filtered
}

func filterInts(is []int, fn func(int) bool) []int {
	var filtered []int
	for _, i := range is {
		if fn(i) {
			filtered = append(filtered, i)
		}
	}
	return filtered
}

func door(rb *Bounds, dir Direction) Tile {
	var x, y int
	switch dir {
	case North:
		x = randInt(rb.min.x+1, rb.max.x-1)
		y = rb.min.y
	case South:
		x = randInt(rb.min.x+1, rb.max.x-1)
		y = rb.max.y
	case East:
		x = rb.max.x
		y = randInt(rb.min.y+1, rb.max.y-1)
	case West:
		x = rb.min.x
		y = randInt(rb.min.y+1, rb.max.y-1)
	}
	return Tile{x: x, y: y, terrain: Door}
}

func staircase(qs []Quadrant) Tile {
	t := Tile{terrain: Staircase}
	ids := rand.Perm(len(qs))
	for _, id := range ids {
		if r := qs[id].room; r != nil {
			t.x = randInt(r.min.x+1, r.max.x-1)
			t.y = randInt(r.min.y+1, r.max.y-1)
			break
		}
	}
	return t
}

func tiles(qs []Quadrant, ps [][]Tile, sc Tile) [][]*Tile {
	tiles := make([][]*Tile, MaxY)
	for i := 0; i < len(tiles); i++ {
		tiles[i] = make([]*Tile, MaxX)
	}

	for _, q := range qs {
		rb := q.room
		if rb == nil {
			continue
		}
		for _, y := range []int{rb.min.y, rb.max.y} {
			for x := rb.min.x; x <= rb.max.x; x++ {
				tiles[y][x] = &Tile{x: x, y: y, terrain: HorizontalWall}
			}
		}
		for y := rb.min.y + 1; y < rb.max.y; y++ {
			for _, x := range []int{rb.min.x, rb.max.x} {
				tiles[y][x] = &Tile{x: x, y: y, terrain: VerticalWall}
			}
			for x := rb.min.x + 1; x < rb.max.x; x++ {
				tiles[y][x] = &Tile{x: x, y: y, terrain: Floor}
			}
		}
	}

	for _, p := range ps {
		for i := 0; i < len(p)-1; i++ {
			vertex := p[i]
			nextVertex := p[i+1]
			if vertex.x != nextVertex.x {
				for x := vertex.x; x <= nextVertex.x; x++ {
					tiles[vertex.y][x] = &Tile{x: x, y: vertex.y, terrain: Passage}
				}
			} else if vertex.y != nextVertex.y {
				for y := vertex.y; y <= nextVertex.y; y++ {
					tiles[y][vertex.x] = &Tile{x: vertex.x, y: y, terrain: Passage}
				}
			}
		}
		for _, p := range ps {
			for _, t := range p {
				tiles[t.y][t.x] = &Tile{x: t.x, y: t.y, terrain: t.terrain}
			}
		}
	}

	tiles[sc.y][sc.x] = &Tile{x: sc.x, y: sc.y, terrain: Staircase}

	for y := 0; y < len(tiles); y++ {
		for x := 0; x < len(tiles[y]); x++ {
			if tiles[y][x] == nil {
				tiles[y][x] = &Tile{x: x, y: y, terrain: NoMansLand}
			}
		}
	}

	return tiles
}

// randInt returns a random integer between min and max (inclusive).
func randInt(min, max int) int {
	return rand.Intn(max-min+1) + min
}

func minInt(a, b int) int {
	if a <= b {
		return a
	}
	return b
}

func maxInt(a, b int) int {
	if a >= b {
		return a
	}
	return b
}
