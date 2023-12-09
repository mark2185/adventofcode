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

func getDiffs(nums []int) []int {
	diffs := make([]int, len(nums)-1)
	for i := 0; i < len(diffs); i++ {
		diffs[i] = nums[i+1] - nums[i]
	}
	return diffs
}

func extrapolateForward(nums []int) int {
	if lo.Every([]int{0}, nums) {
		return 0
	}
	return nums[len(nums)-1] + extrapolateForward(getDiffs(nums))
}

func extrapolateBackward(nums []int) int {
	if lo.Every([]int{0}, nums) {
		return 0
	}
	return nums[0] - extrapolateBackward(getDiffs(nums))
}

func part_one(input []string) {
	sum := 0
	for _, line := range input {
		sum += extrapolateForward(lo.Map(strings.Split(line, " "), parseInt))
	}
	fmt.Println(sum)
}

func part_two(input []string) {
	sum := 0
	for _, line := range input {
		sum += extrapolateBackward(lo.Map(strings.Split(line, " "), parseInt))
	}
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
