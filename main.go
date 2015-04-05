package main

import (
	"fmt"
	flag "github.com/ogier/pflag"
	"os"
)

// Command line flags
var showDependencies bool

func main() {
	flag.BoolVarP(&showDependencies, "makedepend", "d", false,
		"Print template dependencies suitable for a Makefile")

	flag.Parse()

	pp := NewPreprocessor(flag.Args())
	if err := pp.Process(); err != nil {
		fmt.Fprint(os.Stderr, err, "\n")
		os.Exit(1)
	}

	if showDependencies {
		fmt.Print(pp.MakefileDependencies())
	} else {
		fmt.Print(pp.Output)
	}
}
