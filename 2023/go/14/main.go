package main

import (
	"fmt"
	"log"
	"os"
	"sort"
	"strings"

	"github.com/samber/lo"
)

type rock struct {
	y int
	x int
}

type rocks []*rock

type direction int

const (
	north direction = iota
	west
	south
	east
)

type gridInfo struct {
	height          int
	width           int
	movableRocks    rocks
	stationaryRocks rocks
}

func (g *gridInfo) isInBounds(y int, x int) bool {
	return 0 <= y && y < g.height && 0 <= x && x < g.width
}

// squashing all rocks information into a string
func (g *gridInfo) hash() string {
	rs := groupRocks(north, g.movableRocks)
	keys := lo.Keys(rs)
	sort.Ints(keys)
	var sb strings.Builder
	for _, k := range keys {
		for _, r := range rs[k] {
			sb.WriteString(fmt.Sprintf("x%dy%d", r.x, r.y))
		}
	}
	return sb.String()
}

type rockGroups map[int]rocks

// groupByY returns lists of rocks that have the same y coordinate
func groupByY(rs ...*rock) rockGroups {
	groups := rockGroups{}
	for _, r := range rs {
		groups[r.y] = append(groups[r.y], r)
	}
	return groups
}

// groupByX returns lists of rocks that have the same x coordinate
func groupByX(rs ...*rock) rockGroups {
	groups := rockGroups{}
	for _, r := range rs {
		groups[r.x] = append(groups[r.x], r)
	}
	return groups
}

// groups movable rocks based on tilt direction
func groupRocks(d direction, r rocks) rockGroups {
	var groups rockGroups
	switch d {
	case north, south:
		groups = groupByX(r...)
	case west, east:
		groups = groupByY(r...)
	}

	for k, v := range groups {
		switch d {
		case north: // sort Y ascending
			sort.Slice(v, func(a int, b int) bool { return v[a].y < v[b].y })
		case south: // sort Y descending
			sort.Slice(v, func(a int, b int) bool { return v[a].y > v[b].y })
		case west: // sort X ascending
			sort.Slice(v, func(a int, b int) bool { return v[a].x < v[b].x })
		case east: // sort X descending
			sort.Slice(v, func(a int, b int) bool { return v[a].x > v[b].x })
		}
		groups[k] = v
	}
	return groups
}

func (g *gridInfo) calculateWeight() int {
	return lo.Reduce(g.movableRocks, func(acc int, r *rock, _ int) int { return acc + g.height - r.y }, 0)
}

func (g *gridInfo) tilt(d direction) *gridInfo {
	// group and sort them by row/column, based on direction of tilting
	rocksToMove := groupRocks(d, g.movableRocks)
	immovableRocks := groupRocks(d, g.stationaryRocks)

	// for every row/column
	for _, rocksGroup := range rocksToMove {
		for i, r := range rocksGroup {
			nextY := r.y
			nextX := r.x
			for {
				f := func(r *rock) bool { return r.y == nextY && r.x == nextX }
				switch d {
				case north:
					nextY -= 1
				case south:
					nextY += 1
				case west:
					nextX -= 1
				case east:
					nextX += 1
				}
				if !g.isInBounds(nextY, nextX) {
					break
				}
				// another movable rock is there or the position is out of bounds
				if lo.ContainsBy(rocksGroup[:i], f) {
					break
				}
				// an immovable rock is there
				if lo.ContainsBy(immovableRocks[lo.Ternary(d == north || d == south, nextX, nextY)], f) {
					break
				}
				r.y = nextY
				r.x = nextX
			}
		}
	}
	return g
}

func part_one(input []string) any {
	movingRocks := rocks{}
	stationaryRocks := rocks{}
	for y, line := range input {
		for x, c := range line {
			switch c {
			case 'O':
				movingRocks = append(movingRocks, &rock{y, x})
			case '#':
				stationaryRocks = append(stationaryRocks, &rock{y, x})
			}
		}
	}

	g := gridInfo{len(input), len(input[0]), movingRocks, stationaryRocks}
	g.tilt(north)
	return g.calculateWeight()
}

func (g *gridInfo) print() {
	fmt.Println("=================")
	for y := 0; y < 10; y++ {
		for x := 0; x < 10; x++ {
			if lo.ContainsBy(g.movableRocks, func(r *rock) bool { return r.x == x && r.y == y }) {
				fmt.Print("O")
			} else if lo.ContainsBy(g.stationaryRocks, func(r *rock) bool { return r.x == x && r.y == y }) {
				fmt.Print("#")
			} else {
				fmt.Print(".")
			}
		}
		fmt.Println()
	}
	fmt.Println("=================")
}

func part_two(input []string) any {
	movingRocks := rocks{}
	stationaryRocks := rocks{}
	for y, line := range input {
		for x, c := range line {
			switch c {
			case 'O':
				movingRocks = append(movingRocks, &rock{y, x})
			case '#':
				stationaryRocks = append(stationaryRocks, &rock{y, x})
			}
		}
	}

	g := gridInfo{len(input), len(input[0]), movingRocks, stationaryRocks}

	// cache
	hashes := make([]string, 10000)
	remainingIterations := 1000000000
	var cycleLength int
	// find when the data starts looping
	for i := 0; i < remainingIterations; i++ {
		g.tilt(north).tilt(west).tilt(south).tilt(east)
		hash := g.hash()
		if cycleStart := lo.IndexOf(hashes, hash); cycleStart != -1 {
			// cycle detected
			cycleLength = i - cycleStart
			remainingIterations -= i
			break
		}
		hashes[i] = hash
	}

	for i := 1; i < remainingIterations%cycleLength; i++ {
		g.tilt(north).tilt(west).tilt(south).tilt(east)
	}
	return g.calculateWeight()
}

func main() {
	content, err := os.ReadFile("input.txt")
	if err != nil {
		log.Fatal(err)
	}
	input := strings.Split(strings.Trim(string(content), "\n"), "\n")
	fmt.Println(part_one(input))
	fmt.Println(part_two(input))
}
