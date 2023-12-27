package main

import (
	"fmt"
	"log"
	"os"
	"strings"

	"github.com/samber/lo"
)

type rock struct {
	y int
	x int
}

type rocks []rock

type grid struct {
	height int
	width  int
	rs     rocks
}

type rockGroups map[int]rocks

// groupByY returns lists of rocks that have the same y coordinate
func groupByY(rs ...rock) rockGroups {
	groups := rockGroups{}
	for _, r := range rs {
		groups[r.y] = append(groups[r.y], r)
	}
	return groups
}

// groupByX returns lists of rocks that have the same y coordinate
func groupByX(rs ...rock) rockGroups {
	groups := rockGroups{}
	for _, r := range rs {
		groups[r.x] = append(groups[r.x], r)
	}
	return groups
}

func getYs(r rock, _ int) int {
	return r.y
}

func getXs(r rock, _ int) int {
	return r.x
}

func isVerticallyMirrored(a []rock, b []rock) bool {
	aYs := lo.Map(a, getYs)
	bYs := lo.Map(b, getYs)
	return len(a) == len(b) && lo.Every(aYs, bYs)
}

func (g *grid) isVerticalMirrorValid(mirror int) bool {
	groups := groupByX(g.rs...)
	for i := 0; i < min(mirror+1, g.width-mirror-1); i++ {
		if !isVerticallyMirrored(groups[mirror-i], groups[mirror+i+1]) {
			return false
		}
	}
	return true
}

// verticalReflection tries to find a vertical mirror
func (g *grid) verticalReflection() int {
	// mirror will never be at index g.width-1
	for x := 0; x < g.width-1; x++ {
		if g.isVerticalMirrorValid(x) {
			return x + 1
		}
	}
	return -1
}

func isHorizontallyMirrored(a []rock, b []rock) bool {
	aXs := lo.Map(a, getXs)
	bXs := lo.Map(b, getXs)
	return len(a) == len(b) && lo.Every(aXs, bXs)
}

func (g *grid) isHorizontalMirrorValid(mirror int) bool {
	groups := groupByY(g.rs...)
	for i := 0; i < min(mirror+1, g.height-mirror-1); i++ {
		if !isHorizontallyMirrored(groups[mirror-i], groups[mirror+i+1]) {
			return false
		}
	}
	return true
}

// horizontalReflection tries to find a horizontal mirror
func (g *grid) horizontalReflection() int {
	// mirror will never be at index g.height-1
	for y := 0; y < g.height-1; y++ {
		if g.isHorizontalMirrorValid(y) {
			return y + 1
		}
	}
	panic("this can't be happening")
}

func (g *grid) calculateScore() int {
	if v := g.verticalReflection(); v != -1 {
		return v
	}

	return 100 * g.horizontalReflection()
}

func splitInput(input []string) [][]string {
	grid := []string{}
	res := [][]string{}
	for i := 0; i < len(input); i++ {
		line := input[i]
		if line == "" {
			res = append(res, grid)
			grid = []string{}
		} else {
			grid = append(grid, input[i])
		}
	}
	// there is no empty line at the end of input
	return append(res, grid)
}

// 788 too low
func part_one(input []string) any {
	score := 0
	for i, g := range splitInput(input) {
		_ = i
		rs := rocks{}
		for y, line := range g {
			for x, c := range line {
				if c == '#' {
					rs = append(rs, rock{y, x})
				}
			}
		}
		width := len(g[0])
		height := len(g)
		score += (&grid{height: height, width: width, rs: rs}).calculateScore()
	}
	return score
}

func part_two(input []string) any {
	return 0
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
