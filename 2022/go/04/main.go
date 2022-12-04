package main

import (
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"
)

type Range struct {
	LowerBound int
	UpperBound int
}

func partOfRange(r Range, needles ...int) bool {
	for _, n := range needles {
		if !(r.LowerBound <= n && n <= r.UpperBound) {
			return false
		}
	}
	return true
}

func part_one(input []string) {
	count := 0
	for _, line := range input {
		if len(line) == 0 {
			break
		}
		ranges := strings.Split(line, ",")
		left := strings.Split(ranges[0], "-")
		right := strings.Split(ranges[1], "-")
		fstStart, _ := strconv.Atoi(left[0])
		fstEnd, _ := strconv.Atoi(left[1])
		sndStart, _ := strconv.Atoi(right[0])
		sndEnd, _ := strconv.Atoi(right[1])
		if partOfRange(Range{fstStart, fstEnd}, sndStart, sndEnd) ||
			partOfRange(Range{sndStart, sndEnd}, fstStart, fstEnd) {
			count++
		}
	}
	fmt.Println(count)
}

func part_two(input []string) {
	count := 0
	for _, line := range input {
		if len(line) == 0 {
			break
		}
		ranges := strings.Split(line, ",")
		left := strings.Split(ranges[0], "-")
		right := strings.Split(ranges[1], "-")
		fstStart, _ := strconv.Atoi(left[0])
		fstEnd, _ := strconv.Atoi(left[1])
		sndStart, _ := strconv.Atoi(right[0])
		sndEnd, _ := strconv.Atoi(right[1])
		if partOfRange(Range{fstStart, fstEnd}, sndStart) ||
			partOfRange(Range{fstStart, fstEnd}, sndEnd) ||
			partOfRange(Range{sndStart, sndEnd}, fstStart) ||
			partOfRange(Range{sndStart, sndEnd}, fstEnd) {
			count++
		}
	}
	fmt.Println(count)
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
