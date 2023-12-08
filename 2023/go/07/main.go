package main

import (
	"cmp"
	"fmt"
	"log"
	"os"
	"slices"
	"strconv"
	"strings"

	"github.com/samber/lo"
)

func parseInt(s string) int {
	n, _ := strconv.Atoi(s)
	return n
}

type handType int

const (
	HighCard handType = iota
	OnePair
	TwoPair
	ThreeOfAKind
	FullHouse
	FourOfAKind
	FiveOfAKind
)

type hand struct {
	cards string
	bid   int
	t     handType
}

func determineTypeValue(frequency map[rune]int) handType {
	k := lo.Keys(frequency)
	v := lo.Values(frequency)
	switch len(k) {
	case 1:
		return FiveOfAKind
	case 2:
		if lo.Contains(v, 3) {
			return FullHouse
		}
		return FourOfAKind
	case 3:
		if lo.Contains(v, 2) {
			return TwoPair
		}
		return ThreeOfAKind
	case 4:
		return OnePair
	default:
		return HighCard
	}
}

func calculateType(cards string, joker bool) handType {
	frequency := map[rune]int{}
	for _, c := range cards {
		frequency[c]++
	}
	if len(frequency) == 1 {
		return FiveOfAKind
	}

	if _, ok := frequency['J']; ok && joker {
		var maxK rune
		maxV := 0
		for k, v := range frequency {
			if v > maxV {
				maxV = v
				maxK = k
			}
		}
		frequency[maxK] += frequency['J']
		delete(frequency, 'J')
	}
	return determineTypeValue(frequency)
}

func compareHands(left hand, right hand, values map[byte]int) int {
	if c := cmp.Compare(left.t, right.t); c != 0 {
		return c
	}

	for i := 0; i < len(left.cards); i++ {
		a, b := values[left.cards[i]], values[right.cards[i]]
		if c := cmp.Compare(a, b); c != 0 {
			return c
		}
	}
	return 0
}

func part_one(input []string) {
	hands := make([]hand, len(input))
	for i, line := range input {
		s := strings.Split(line, " ")
		cards, bid := s[0], parseInt(s[1])
		hands[i] = hand{cards: cards, bid: bid, t: calculateType(cards, false)}
	}

	values := map[byte]int{
		'2': 2, '3': 3, '4': 4, '5': 5, '6': 6, '7': 7, '8': 8, '9': 9, 'T': 10,
		'J': 11, 'Q': 12, 'K': 13, 'A': 14,
	}

	cmp := func(left hand, right hand) int {
		return compareHands(left, right, values)
	}

	slices.SortFunc(hands, cmp)
	sum := 0
	for i, h := range hands {
		sum += (i + 1) * h.bid
	}
	fmt.Println(sum)
}

func part_two(input []string) {
	hands := make([]hand, len(input))
	for i, line := range input {
		s := strings.Split(line, " ")
		cards, bid := s[0], parseInt(s[1])
		hands[i] = hand{cards: cards, bid: bid, t: calculateType(cards, true)}
	}

	values := map[byte]int{
		'J': 1, '2': 2, '3': 3, '4': 4, '5': 5, '6': 6, '7': 7, '8': 8, '9': 9, 'T': 10,
		'Q': 12, 'K': 13, 'A': 14,
	}

	cmp := func(left hand, right hand) int {
		return compareHands(left, right, values)
	}

	slices.SortFunc(hands, cmp)
	sum := 0
	for i, h := range hands {
		sum += (i + 1) * h.bid
	}
	// 245899795 too high
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
