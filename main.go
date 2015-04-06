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

func main() {
	showDependencies := flag.BoolP("make", "M", false,
		"Print template dependencies suitable for a Makefile")
	loadPaths := flag.StringP("include", "I", "",
		"Add paths to search for templates")
	showVersion := flag.BoolP("version", "v", false,
		"Print the version of "+os.Args[0])
	flag.Parse()

	if *showVersion {
		fmt.Println(VERSION)
		os.Exit(0)
	}

	err := AddTemplatePaths(*loadPaths)
	assertNilErr(err)

	AddTemplatePaths(CWD)

	pp := NewPreprocessor(flag.Args())
	err = pp.Process()
	assertNilErr(err)

	if *showDependencies {
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
