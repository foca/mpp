package main

import (
	"fmt"
	flag "github.com/ogier/pflag"
	"io"
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
	showHelp := flag.BoolP("help", "h", false,
		"Print this help message")

	flag.Parse()

	if *showVersion {
		fmt.Println(os.Args[0], "version", VERSION)
		os.Exit(0)
	}

	if *showHelp {
		Usage(os.Stdout)
		os.Exit(0)
	}

	if len(flag.Args()) == 0 {
		Usage(os.Stderr)
		os.Exit(1)
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

func Usage(out io.Writer) {
	fmt.Fprintf(out, HELP, os.Args[0], os.Args[0])
}

const HELP = `Usage: %s [options] files...

    mpp is a mini preprocessor.

Options:

    -I, --include=[<dir>:<dir>...]: Include dirs in the template search path.
    -M, --make:                     Print Make-style dependencies.
    -v, --version:                  Print the current version of %s.
    -h, --help:                     Print this help text.

`
