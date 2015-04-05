package main

import (
	"fmt"
	"os"
)

func main() {
	pp := NewPreprocessor(os.Args[1:])
	if err := pp.Process(); err != nil {
		fmt.Fprint(os.Stderr, err, "\n")
		os.Exit(1)
	}

	fmt.Print(pp.Output)
}
