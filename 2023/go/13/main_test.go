package main

import (
	"os"
	"strings"
	"testing"
)

func TestPartOne(t *testing.T) {
	inputs := []string{"example.txt", "input.txt"}
	wants := []any{405, 0}
	for i := 0; i < len(inputs); i++ {
		content, err := os.ReadFile(inputs[i])
		if err != nil {
			t.Fatalf("Failed reading file: %v", err)
		}
		input := strings.Split(strings.Trim(string(content), "\n"), "\n")
		want := wants[i]
		result := part_one(input)
		if result != want {
			t.Fatalf("Result was %v instead of %v\n", result, want)
		}
	}
}

func TestPartTwo(t *testing.T) {
	inputs := []string{"example.txt", "input.txt"}
	wants := []any{0, 0}
	for i := 0; i < len(inputs); i++ {
		content, err := os.ReadFile(inputs[i])
		if err != nil {
			t.Fatalf("Failed reading file: %v", err)
		}
		input := strings.Split(strings.Trim(string(content), "\n"), "\n")
		want := wants[i]
		result := part_two(input)
		if result != want {
			t.Fatalf("Result was %v instead of %v\n", result, want)
		}
	}
}
