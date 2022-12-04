package main

import (
	"fmt"
	"log"
	"os"
	"strings"
)

const (
	WIN_val           = 6
	DRAW_val          = 3
	LOSE_val          = 0
	Rock_val          = 1
	Paper_val         = 2
	Scissors_val      = 3
	WIN               = "Z"
	DRAW              = "Y"
	LOSE              = "X"
	Opponent_Rock     = "A"
	Opponent_Paper    = "B"
	Opponent_Scissors = "C"
	Me_Rock           = "X"
	Me_Paper          = "Y"
	Me_Scissors       = "Z"
)

func getScore(me string, opponent string) int {
	switch opponent {
	case Opponent_Rock:
		switch me {
		case Me_Paper:
			return WIN_val
		case Me_Rock:
			return DRAW_val
		}
	case Opponent_Paper:
		switch me {
		case Me_Scissors:
			return WIN_val
		case Me_Paper:
			return DRAW_val
		}
	case Opponent_Scissors:
		switch me {
		case Me_Rock:
			return WIN_val
		case Me_Scissors:
			return DRAW_val
		}
	}
	return LOSE_val
}

func part_one(input []string) {
	score := 0
	scores := map[string]int{Me_Rock: Rock_val, Me_Paper: Paper_val, Me_Scissors: Scissors_val}
	for _, line := range input {
		if len(line) == 0 {
			break
		}
		moves := strings.Split(line, " ")
		opponent, me := moves[0], moves[1]
		score += scores[me] + getScore(me, opponent)
	}
	fmt.Println(score)
}

func part_two(input []string) {
	score := 0
	opponentScores := map[string]int{Opponent_Rock: Rock_val, Opponent_Paper: Paper_val, Opponent_Scissors: Scissors_val}
	moves := map[string]int{LOSE: LOSE_val, DRAW: DRAW_val, WIN: WIN_val}
	for _, line := range input {
		if len(line) == 0 {
			break
		}
		playedMoves := strings.Split(line, " ")
		opponent, neededOutcome := playedMoves[0], playedMoves[1]
		score += moves[neededOutcome]
		if neededOutcome == DRAW {
			score += opponentScores[opponent]
		}
		switch opponent {
		case Opponent_Rock:
			switch neededOutcome {
			case WIN:
				score += Paper_val
			case LOSE:
				score += Scissors_val
			}
		case Opponent_Paper:
			switch neededOutcome {
			case WIN:
				score += Scissors_val
			case LOSE:
				score += Rock_val
			}
		case Opponent_Scissors:
			switch neededOutcome {
			case WIN:
				score += Rock_val
			case LOSE:
				score += Paper_val
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
