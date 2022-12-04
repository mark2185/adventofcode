package main

import (
	"fmt"
	"log"
	"os"
	"strings"
)

func part_one(input []string) {
	score := 0
	for _, line := range input {
		leftRucksack, rightRucksack := line[:len(line)/2], line[len(line)/2:]
		for _, leftItem := range leftRucksack {
			if strings.Contains(rightRucksack, string(leftItem)) {
				if leftItem > 97 {
					score += int(leftItem) - 96
				} else {
					score += int(leftItem) - 38
				}
				break
			}
		}
	}
	fmt.Println(score)
}

func part_two(input []string) {
	score := 0
	for i := 0; i < len(input)-2; i += 3 {
		items := map[rune](int){}
		for j := 0; j < 3; j++ {
			for _, item := range input[i+j] {
				items[item] |= 1 << j
			}
		}
		for k, v := range items {
			if v == 7 {
				if k > 97 {
					score += int(k) - 96
				} else {
					score += int(k) - 38
				}
				break
			}
		}
	}
	fmt.Println(score)
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
