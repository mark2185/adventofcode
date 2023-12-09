package main

import (
	"fmt"
	"log"
	"os"
	"regexp"
	"strings"
)

type nodeData struct {
	value string
	left  string
	right string
}

type node struct {
	value string
	left  *node
	right *node
}

func parse(data string, pattern *regexp.Regexp) (string, string, string) {
	matches := pattern.FindStringSubmatch(data)
	return matches[1], matches[2], matches[3]
}

func find(needle string, haystack []*node) *node {
	for i, n := range haystack {
		if needle == n.value {
			return haystack[i]
		}
	}
	return nil
}

func constructTree(input []string) []*node {
	pattern, _ := regexp.Compile(`(\w+) = \((\w+), (\w+)\)`)
	data := make([]nodeData, len(input))
	nodes := make([]*node, len(input))
	for i, line := range input {
		v, l, r := parse(line, pattern)
		data[i] = nodeData{v, l, r}
		nodes[i] = &node{value: v}
	}

	for i := 0; i < len(nodes); i++ {
		d := data[i]
		n := find(d.value, nodes)
		n.left = find(d.left, nodes)
		n.right = find(d.right, nodes)
	}

	return nodes
}

func part_one(input []string) {
	moves := input[0]
	nodes := constructTree(input[2:])

	steps := 0
	currentNode := find("AAA", nodes)
	for ; currentNode.value != "ZZZ"; steps++ {
		switch moves[steps%len(moves)] {
		case 'L':
			currentNode = currentNode.left
		case 'R':
			currentNode = currentNode.right
		}
	}
	fmt.Println(steps)
}

func part_two(input []string) {
	moves := input[0]
	nodes := constructTree(input[2:])

	currentNodes := []*node{}
	for i, n := range nodes {
		if strings.HasSuffix(n.value, "A") {
			currentNodes = append(currentNodes, nodes[i])
		}
	}

	steps := make([]int, len(currentNodes))
	for i := range currentNodes {
		currentNode := currentNodes[i]
		s := 0
		for ; !strings.HasSuffix(currentNode.value, "Z"); s++ {
			switch moves[s%len(moves)] {
			case 'L':
				currentNode = currentNode.left
			case 'R':
				currentNode = currentNode.right
			}
		}
		steps[i] = int(s)
	}

	fmt.Println(lcm(steps[0], steps[1], steps[2:]...))
}

func gcd(a int, b int) int {
	for b != 0 {
		t := b
		b = a % b
		a = t
	}
	return a
}

func lcm(a int, b int, integers ...int) int {
	result := a * b / gcd(a, b)

	for i := 0; i < len(integers); i++ {
		result = lcm(result, integers[i])
	}

	return result
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
