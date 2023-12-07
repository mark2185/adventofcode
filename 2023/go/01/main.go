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
	for _, line := range input {
		digits := ""
		for i := 0; i < len(line); i++ {
			c := line[i]
			if c >= '0' && c <= '9' {
				digits += string(c)
				break
			}
		}
		for i := len(line) - 1; i >= 0; i-- {
			c := line[i]
			if c >= '0' && c <= '9' {
				digits += string(c)
				break
			}
		}
		n, _ := strconv.Atoi(digits)
		sum += n
	}
	fmt.Println(sum)
}

func part_two(input []string) {
	sum := 0
	digitWords := map[string]string{
		"one":   "1",
		"two":   "2",
		"three": "3",
		"four":  "4",
		"five":  "5",
		"six":   "6",
		"seven": "7",
		"eight": "8",
		"nine":  "9",
	}
	findDigit := func(line string, start int, end int, step int) string {
		for i := start; i != end; i += step {
			c := line[i]
			if c >= '0' && c <= '9' {
				return string(c)
			} else {
				// match word from current index
				for k, v := range digitWords {
					if k == line[i:min(i+len(k), len(line))] {
						return v
					}
				}
			}
		}
		return "0"
	}

	for _, line := range input {
		digits := findDigit(line, 0, len(line), 1) +
			findDigit(line, len(line)-1, -1, -1)

		n, _ := strconv.Atoi(digits)
		sum += n
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
