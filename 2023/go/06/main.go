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

func parseInt(s string) int {
	n, _ := strconv.Atoi(s)
	return n
}

func mapParseInt(s string, _ int) int {
	return parseInt(s)
}

func notEmpty(s string, _ int) bool {
	return s != ""
}

func solveQuadratic(ai int, bi int, ci int) (float64, float64) {
	a, b, c := float64(ai), float64(bi), float64(ci)
	discriminant := b*b - 4*a*c
	upper := (-b + math.Sqrt(discriminant)) / 2 * a
	lower := (-b - math.Sqrt(discriminant)) / 2 * a
	return lower, upper
}

func part_one(input []string) {
	times := lo.Map(lo.Filter(strings.Split(input[0], " ")[1:], notEmpty), mapParseInt)
	distances := lo.Map(lo.Filter(strings.Split(input[1], " ")[1:], notEmpty), mapParseInt)

	result := 1
	for i := 0; i < len(times); i++ {
		t := times[i]
		d := distances[i]
		a, b, c := 1, -t, d
		lower, upper := solveQuadratic(a, b, c)
		result *= (int(math.Ceil(upper)) - 1) - (int(lower + 1)) + 1
	}
	fmt.Println(result)
}

func part_two(input []string) {
	t := parseInt(strings.Replace(strings.Split(input[0], ":")[1], " ", "", -1))
	d := parseInt(strings.Replace(strings.Split(input[1], ":")[1], " ", "", -1))

	a, b, c := 1, -t, d
	lower, upper := solveQuadratic(a, b, c)
	fmt.Println((int(math.Ceil(upper)) - 1) - (int(lower + 1)) + 1)
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
