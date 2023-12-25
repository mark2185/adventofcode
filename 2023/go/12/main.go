package main

import (
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"

	"github.com/samber/lo"
)

func parseInt(line string, _ int) int {
	n, _ := strconv.Atoi(line)
	return n
}

func part_one(input []string) any {
	sum := 0
	for _, line := range input {
		s := strings.Split(line, " ")
		nums := lo.Map(strings.Split(s[1], ","), parseInt)

		sum += recursion(s[0], nums, 0, map[string]int{})
	}
	return sum
}

func transformIntoKey(data string, counts []int) string {
	return data + "|" + strings.Join(lo.Map(counts, func(x int, _ int) string { return fmt.Sprint(x) }), ",")
}

func recursion(data string, expectedCounts []int, count int, memo map[string]int) int {
	if val, ok := memo[transformIntoKey(data, expectedCounts)]; ok {
		return val
	}

	if len(expectedCounts) == 0 {
		if strings.Contains(data, "#") {
			return 0
		}
		return 1
	}

	if data == "" {
		return 0
	}

	switch c := data[0]; c {
	case '?':
		sum := recursion(strings.Replace(data, "?", "#", 1), expectedCounts, count, memo)
		sum += recursion(strings.Replace(data, "?", ".", 1), expectedCounts, count, memo)
		memo[transformIntoKey(data, expectedCounts)] = sum
		return sum
	case '#':
		count++
		expectedCount := expectedCounts[0]

		// not yet enough
		if count < expectedCount {
			// we reached the end of sequence (or data)
			if len(data) == 1 || data[1] == '.' {
				return 0
			}

			// the next one has to be '#' or '?', this covers both
			// when it _is_ a '#' and when it's a '?'
			return recursion("#"+data[2:], expectedCounts, count, memo)
		}

		// lagom, but we need to check if we reached the end of the sequence (or data)
		if len(data) == 1 {
			return recursion("", expectedCounts[1:], 0, memo)
		}

		// this means the sequence is too long
		if data[1] == '#' {
			return 0
		}
		// the next one has to be '.' or '?', this covers both
		// when it _is_ a '.' and when it's a '?'
		return recursion("."+data[2:], expectedCounts[1:], 0, memo)
	}
	return recursion(data[1:], expectedCounts, 0, memo)
}

func part_two(input []string) any {
	sum := 0
	for _, line := range input {
		split := strings.Split(line, " ")
		left := split[0]
		right := lo.Map(strings.Split(split[1], ","), parseInt)

		s := []string{}
		n := []int{}
		for i := 0; i < 5; i++ {
			s = append(s, left)
			n = append(n, right...)
		}
		graphs := strings.Join(s, "?")

		sum += recursion(graphs, n, 0, map[string]int{})
	}
	return sum
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
