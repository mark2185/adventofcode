package main

import (
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"
)

func part_one(input []string) {
	sum := 0
	maxNums := map[string]int{
		"red":   12,
		"green": 13,
		"blue":  14,
	}
	for i, line := range input {
		if line == "" {
			break
		}
		games := strings.Split(line, ":")
		validGame := true
		for _, round := range strings.Split(games[1], ";") {
			cubes := strings.Split(round, ",")
			for _, c := range cubes {
				splits := strings.Split(strings.Trim(c, " "), " ")
				n, _ := strconv.Atoi(splits[0])
				color := splits[1]
				validGame = validGame && n <= maxNums[color]
			}
		}
		if validGame {
			sum += i + 1
		}
	}
	fmt.Println(sum)
}

func max(a int, b int) int {
	if a > b {
		return a
	}
	return b
}

func part_two(input []string) {
	sum := 0
	for _, line := range input {
		if line == "" {
			break
		}
		games := strings.Split(line, ":")
		maxCubes := map[string]int{}
		for _, round := range strings.Split(games[1], ";") {
			cubes := strings.Split(round, ",")
			for _, c := range cubes {
				splits := strings.Split(strings.Trim(c, " "), " ")
				n, _ := strconv.Atoi(splits[0])
				color := splits[1]
				maxCubes[color] = max(maxCubes[color], n)
			}
		}
		roundValue := 1
		for _, v := range maxCubes {
			roundValue *= v
		}
		sum += roundValue
	}
	fmt.Println(sum)
}

func main() {
	content, err := os.ReadFile("input.txt")
	if err != nil {
		log.Fatal(err)
	}
	input := strings.Split(string(content), "\n")
	part_one(input)
	part_two(input)
}
