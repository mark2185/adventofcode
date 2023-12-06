package main

import (
	"fmt"
	"log"
	"math"
	"os"
	"strconv"
	"strings"

	"github.com/samber/lo"
)

type mapping struct {
	target int
	source int
	step   int
}

type maps []mapping

func parseInt(line string, _ int) int {
	n, _ := strconv.Atoi(line)
	return n
}

func readMap(input []string) ([]string, maps) {
	res := []mapping{}
	cutoff := 0
	for _, line := range input[1:] {
		cutoff += 1
		if line == "" {
			break
		}
		nums := lo.Map(strings.Split(line, " "), parseInt)
		target, source, step := nums[0], nums[1], nums[2]
		res = append(res, mapping{target: target, source: source, step: step})
	}
	return input[cutoff+1:], res
}

func resolve(x int, m maps) int {
	for _, r := range m {
		source, step, target := r.source, r.step, r.target
		if source <= x && x < (source+step) {
			return target + (x - source)
		}
	}
	return x
}

func part_one(input []string) {
	seeds := lo.Map(strings.Split(input[0], " ")[1:], parseInt)

	input = input[2:]
	input, seed2soil := readMap(input)
	input, soil2fertilizer := readMap(input)
	input, fertilizer2water := readMap(input)
	input, water2light := readMap(input)
	input, light2temperature := readMap(input)
	input, temperature2humidity := readMap(input)
	input, humidity2location := readMap(input)

	almanac := []maps{seed2soil, soil2fertilizer, fertilizer2water, water2light, light2temperature, temperature2humidity, humidity2location}

	lowest := math.MaxInt
	for _, s := range seeds {
		final := s
		for _, a := range almanac {
			final = resolve(final, a)
		}
		lowest = min(lowest, final)
	}
	fmt.Println(lowest)
}

func part_two(input []string) {
	seeds := lo.Map(strings.Split(input[0], " ")[1:], parseInt)

	input = input[2:]
	input, seed2soil := readMap(input)
	input, soil2fertilizer := readMap(input)
	input, fertilizer2water := readMap(input)
	input, water2light := readMap(input)
	input, light2temperature := readMap(input)
	input, temperature2humidity := readMap(input)
	input, humidity2location := readMap(input)

	almanac := []maps{seed2soil, soil2fertilizer, fertilizer2water, water2light, light2temperature, temperature2humidity, humidity2location}

	c := make(chan int)
	for i := 0; i < len(seeds); i += 2 {
		start, end := seeds[i], seeds[i+1]
		go func(c chan int) {
			lowest := math.MaxInt
			for s := start; s < start+end; s++ {
				final := s
				for _, a := range almanac {
					final = resolve(final, a)
				}
				lowest = min(lowest, final)
			}
			c <- lowest
		}(c)
	}
	lowest := math.MaxInt
	for i := 0; i < len(seeds)/2; i++ {
		lowest = min(lowest, <-c)
	}
	fmt.Println(lowest)
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
