package main

import (
	"fmt"
	"log"
	"os"
	"sort"
	"strconv"
	"strings"
)

func part_one(input []string) {
	var max_calories int64 = 0
	var sum int64 = 0
	for _, line := range input {
		if len(line) == 0 {
			if sum > max_calories {
				max_calories = sum
			}
			sum = 0
			continue
		}
		calories, _ := strconv.ParseInt(line, 10, 64)
		sum += calories
	}
	fmt.Println(max_calories)
}

func part_two(input []string) {
	caloriesPerElf := []int{}

	var sum int = 0
	for _, line := range input {
		if len(line) == 0 {
			caloriesPerElf = append(caloriesPerElf, sum)
			sum = 0
			continue
		}
		calories, _ := strconv.ParseInt(line, 10, 64)
		sum += int(calories)
	}
	sort.Sort(sort.Reverse(sort.IntSlice(caloriesPerElf)))
	fmt.Println(caloriesPerElf[0] + caloriesPerElf[1] + caloriesPerElf[2])
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
