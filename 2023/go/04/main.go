package main

import (
	"fmt"
	"log"
	"os"
	str "strings"

	"github.com/samber/lo"
)

func contains(winning []string, number string) bool {
	for _, w := range winning {
		if w == number {
			return true
		}
	}
	return false
}

func count(winning []string, drawn []string) int {
	count := 0
	for _, d := range drawn {
		if contains(winning, d) {
			count++
		}
	}
	return count
}

func splitOnSpace(s string, _ int) []string {
	return str.Split(s, " ")
}

func part_one(input []string) {
	score := 0
	for _, cards := range lo.Map(input, func(line string, _ int) []string { return str.Split(str.Split(line, ": ")[1], "|") }) {
		c := lo.Map(cards, splitOnSpace)
		winning := lo.WithoutEmpty(c[0])
		drawn := lo.WithoutEmpty(c[1])
		count := count(winning, drawn)
		if count > 0 {
			score += 1 << (count - 1)
		}
	}
	fmt.Println(score)
}

type card struct {
	id      int
	winning []string
	drawn   []string
}

func part_two(input []string) {
	original_cards := []card{}
	for i, cards := range lo.Map(input, func(l string, _ int) []string { return str.Split(str.Split(l, ": ")[1], "|") }) {
		c := lo.Map(cards, splitOnSpace)
		w := lo.WithoutEmpty(c[0])
		d := lo.WithoutEmpty(c[1])
		original_cards = append(original_cards, card{id: i + 1, winning: w, drawn: d})
	}

	result := 0
	cards_to_inspect := original_cards[:]
	var current_card card
	for ; ; result += 1 {
		if len(cards_to_inspect) == 0 {
			break
		}
		current_card, cards_to_inspect = cards_to_inspect[0], cards_to_inspect[1:]
		id, w, d := current_card.id, current_card.winning, current_card.drawn
		count := count(w, d)
		for i := id + 1; i <= id+count; i++ {
			cards_to_inspect = append(cards_to_inspect, original_cards[i-1])
		}
		if result == 20 {
			break
		}
	}
	fmt.Println(result)
}

func main() {
	content, err := os.ReadFile("input.txt")
	if err != nil {
		log.Fatal(err)
	}
	input := str.Split(str.Trim(string(content), "\n"), "\n")
	part_one(input)
	part_two(input)
}
