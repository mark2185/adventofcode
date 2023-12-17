package main

import (
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"
)

func hash(input string) int {
    acc := 0
    for _, c := range input {
        acc = ( (acc + int(c)) * 17 ) % 256
    }
    return acc
}

func part_one(input []string) {
    sum := 0
    for _, data := range strings.Split(input[0], ",") {
        sum += hash(data)
    }
    fmt.Println(sum)
}

type lens struct {
    label string
    length int
}

type lenses []lens

func parseInt(n string) int {
    res, _ := strconv.Atoi(n);
    return res
}

func addToBox(boxes map[int]lenses, l lens) {
    boxIndex := hash(l.label)
    box, exists := boxes[boxIndex]
    if !exists {
        // box contains nothing, insert lens
        boxes[boxIndex] = lenses{l}
        return
    }

    // try to find the same lens and overwrite it
    for i, e := range box {
        if e.label == l.label {
            box[i] = l
            return
        }
    }

    // lens `l` is completely new
    boxes[boxIndex] = append(box, l)
}

func removeFromBox(boxes map[int]lenses, label string) {
    boxIndex := hash(label)
    box, exists := boxes[boxIndex]
    if !exists {
        return
    }

    for i, l := range box {
        if l.label == label {
            boxes[boxIndex] = append(box[:i], box[i+1:]...)
            break
        }
    }
}


func part_two(input []string) {
    boxes := map[int]lenses{}
    for _, data := range strings.Split(input[0], ",") {
        s := strings.FieldsFunc(data, func(r rune) bool { return r == '=' || r == '-' } )
        label, value := s[0], s[1:]
        if len(value) == 0 {
            // it was a "label-,..."
            removeFromBox(boxes, label)
        } else {
            focal_length := parseInt(value[0])
            l := lens{ label, focal_length }
            addToBox(boxes, l)
        }
    }
    sum := 0
    for i, box := range boxes {
        acc := 0
        for j, l := range box {
            acc += (j+1) * l.length
        }
        sum += (i+1) * acc
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
