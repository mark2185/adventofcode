package main

import (
	"fmt"
	"log"
	"os"
	"runtime/pprof"
	"strings"
)

func part_one(input []string) any {
	return 0
}

func part_two(input []string) any {
	return 0
}

func main() {
	content, err := os.ReadFile("input.txt")
	if err != nil {
		log.Fatal(err)
	}
	input := strings.Split(strings.Trim(string(content), "\n"), "\n")

	f, err := os.Create("cpu.pprof")
	if err != nil {
		panic(err)
	}
	pprof.StartCPUProfile(f)
	defer pprof.StopCPUProfile()

	fmt.Println(part_one(input))
	fmt.Println(part_two(input))
}
