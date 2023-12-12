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

func part_one(grid []string) {
	originalPlanets := []planet{}
	for y, line := range grid {
		for x, c := range line {
			if c == '#' {
				originalPlanets = append(originalPlanets, planet{y, x})
			}
		}
	}

	movedPlanets := make([]planet, len(originalPlanets))
	copy(movedPlanets, originalPlanets)
	emptyRow := strings.Repeat(".", len(grid[0]))
	for y, row := range grid {
		if row == emptyRow {
			for i, p := range originalPlanets {
				if p.y > y {
					movedPlanets[i].y += 1
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
					movedPlanets[i].x += 1
				}
			}
		}
	}
	sum := 0
	for i := 0; i < len(originalPlanets); i++ {
		a := movedPlanets[i]
		for j := i + 1; j < len(originalPlanets); j++ {
			b := movedPlanets[j]
			distance := abs(b.x-a.x) + abs(b.y-a.y)
			sum += distance
		}
	}
	fmt.Println(sum)
}

func part_two(grid []string) {
	originalPlanets := []planet{}
	for y, line := range grid {
		for x, c := range line {
			if c == '#' {
				originalPlanets = append(originalPlanets, planet{y, x})
			}
		}
	}

	movedPlanets := make([]planet, len(originalPlanets))
	copy(movedPlanets, originalPlanets)
	emptyRow := strings.Repeat(".", len(grid[0]))
	for y, row := range grid {
		if row == emptyRow {
			for i, p := range originalPlanets {
				if p.y > y {
					movedPlanets[i].y += 999999
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
					movedPlanets[i].x += 999999
				}
			}
		}
	}
	sum := 0
	for i := 0; i < len(originalPlanets); i++ {
		a := movedPlanets[i]
		for j := i + 1; j < len(originalPlanets); j++ {
			b := movedPlanets[j]
			distance := abs(b.x-a.x) + abs(b.y-a.y)
			sum += distance
		}
	}
	fmt.Println(sum)

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
