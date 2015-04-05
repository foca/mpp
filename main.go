package main

import (
	"flag"
	"fmt"
	"os"
)

func main() {
	dependencies := flag.Bool("makedepend", false,
		"Print template dependencies suitable for a Makefile")
	flag.Parse()

	pp := NewPreprocessor(flag.Args())
	if err := pp.Process(); err != nil {
		fmt.Fprint(os.Stderr, err, "\n")
		os.Exit(1)
	}

	if *dependencies {
		fmt.Print(pp.MakefileDependencies())
	} else {
		fmt.Print(pp.Output)
	}
}
