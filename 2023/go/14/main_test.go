package main

import (
	"os"
	"strings"
	"testing"
)

func TestPartOne(t *testing.T) {
	content, err := os.ReadFile("sample.txt")
	if err != nil {
		t.Fatalf("Failed reading sample file: %v", err)
	}
	input := strings.Split(strings.Trim(string(content), "\n"), "\n")
	want := 136
	result := part_one(input)
	if result != want {
		t.Fatalf("Result was %d instead of %d\n", result, want)
	}
}

func TestPartTwo(t *testing.T) {
	content, err := os.ReadFile("sample.txt")
	if err != nil {
		t.Fatalf("Failed reading sample file: %v", err)
	}
	input := strings.Split(strings.Trim(string(content), "\n"), "\n")
	want := 64
	result := part_two(input)
	if result != want {
		t.Fatalf("Result was %d instead of %d\n", result, want)
	}
}
