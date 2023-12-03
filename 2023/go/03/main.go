package main

import (
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"
)

func isDigit(c uint8) bool {
	return '0' <= c && c <= '9'
}

func min(a int, b int) int {
	if a < b {
		return a
	}
	return b
}

func max(a int, b int) int {
	if a > b {
		return a
	}
	return b
}

func hasAdjacentSymbol(schema []string, row int, col int) bool {
	for y := max(0, row-1); y <= min(row+1, len(schema)-1); y++ {
		line := schema[y]
		for x := max(0, col-1); x <= min(col+1, len(line)-1); x++ {
			c := line[x]
			if !isDigit(c) && c != '.' {
				return true
			}
		}
	}
	return false
}

func part_one(input []string) {
	sum := 0
	for y := 0; y < len(input); y++ {
		num := ""
		isPartNumber := false
		line := input[y]
		for x := 0; x < len(line); x++ {
			c := line[x]
			if isDigit(c) {
				num += string(c)
				isPartNumber = isPartNumber || hasAdjacentSymbol(input, y, x)
			} else {
				if isPartNumber {
					n, _ := strconv.Atoi(num)
					sum += n
				}
				isPartNumber = false
				num = ""
			}
		}
		// right edge case
		if isPartNumber {
			n, _ := strconv.Atoi(num)
			sum += n
		}
	}
	fmt.Println(sum)
}

type symbol struct {
	y, x int
}

type part struct {
	value int
	s     symbol
}

func hasAdjacentAsterisk(schema []string, row int, col int) (symbol, bool) {
	for y := max(0, row-1); y <= min(row+1, len(schema)-1); y++ {
		line := schema[y]
		for x := max(0, col-1); x <= min(col+1, len(line)-1); x++ {
			c := line[x]
			if c == '*' {
				return symbol{y, x}, true
			}
		}
	}
	return symbol{}, false
}

func part_two(input []string) {
	parts := []part{}
	for y := 0; y < len(input); y++ {
		num := ""
		s := symbol{}
		isPartNumber := false
		line := input[y]
		for x := 0; x < len(line); x++ {
			c := line[x]
			if isDigit(c) {
				num += string(c)
				if asterisk, ok := hasAdjacentAsterisk(input, y, x); ok {
					s = asterisk
					isPartNumber = true
				}
			} else {
				if isPartNumber {
					n, _ := strconv.Atoi(num)
					parts = append(parts, part{n, s})
				}
				s = symbol{}
				num = ""
				isPartNumber = false
			}
		}
		// right edge case
		if isPartNumber {
			n, _ := strconv.Atoi(num)
			parts = append(parts, part{n, s})
		}
	}

	sum := 0
	for len(parts) > 0 {
		var p part
		p, parts = parts[0], parts[1:]
		for _, part := range parts {
			if p.s == part.s {
				sum += p.value * part.value
			}
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
