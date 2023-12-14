package main

import (
	"fmt"
	"log"
	"os"
	"strings"
)

type planet struct {
	y int
	x int
}

func abs(x int) int {
	if x < 0 {
		return -x
	}
	return x
}

func expandSpace(grid []string, originalPlanets []planet, expansionFactor int) []planet {
	movedPlanets := make([]planet, len(originalPlanets))
	copy(movedPlanets, originalPlanets)
	emptyRow := strings.Repeat(".", len(grid[0]))
	for y, row := range grid {
		if row == emptyRow {
			for i, p := range originalPlanets {
				if p.y > y {
					movedPlanets[i].y += expansionFactor
				}
			}
		}
	}
	for x := 0; x < len(grid[0]); x++ {
		emptyColumn := true
		for y := 0; y < len(grid); y++ {
			if grid[y][x] == '#' {
				emptyColumn = false
				break
			}
		}
		if emptyColumn {
			for i, p := range originalPlanets {
				if p.x > x {
					movedPlanets[i].x += expansionFactor
				}
			}
		}
	}
	return movedPlanets
}

func calculateExpansion(grid []string, expansionFactor int) int {
	originalPlanets := []planet{}
	for y, line := range grid {
		for x, c := range line {
			if c == '#' {
				originalPlanets = append(originalPlanets, planet{y, x})
			}
		}
	}
	movedPlanets := expandSpace(grid, originalPlanets, expansionFactor)
	sum := 0
	for i := 0; i < len(originalPlanets); i++ {
		a := movedPlanets[i]
		for j := i + 1; j < len(originalPlanets); j++ {
			b := movedPlanets[j]
			distance := abs(b.x-a.x) + abs(b.y-a.y)
			sum += distance
		}
	}
	return sum
}

func part_one(grid []string) {
	fmt.Println(calculateExpansion(grid, 1))
}

func part_two(grid []string) {
	fmt.Println(calculateExpansion(grid, 999999))
}

func main() {
	content, err := os.ReadFile("input.txt")
	if err != nil {
		log.Fatal(err)
	}
	input := strings.Split(strings.Trim(string(content), "\n"), "\n")
	part_one(input)
	part_two(input)
}
