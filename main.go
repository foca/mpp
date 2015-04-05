package main

import (
	"fmt"
	flag "github.com/ogier/pflag"
	"os"
)

var CWD = getCurDir()

func getCurDir() string {
	dir, err := os.Getwd()
	assertNilErr(err)
	return dir
}

// Command line flags
var showDependencies bool
var loadPath string

func main() {
	flag.BoolVarP(&showDependencies, "makedepend", "d", false,
		"Print template dependencies suitable for a Makefile")
	flag.StringVarP(&loadPath, "include", "I", CWD,
		"Add paths to search for templates")
	flag.Parse()

	err := AddTemplatePaths(loadPath)
	assertNilErr(err)

	pp := NewPreprocessor(flag.Args())
	err = pp.Process()
	assertNilErr(err)

	if showDependencies {
		fmt.Print(pp.MakefileDependencies())
	} else {
		fmt.Print(pp.Output)
	}
}

func assertNilErr(err error) {
	if err != nil {
		fmt.Fprint(os.Stderr, err, "\n")
		os.Exit(1)
	}
}
