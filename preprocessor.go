package main

import (
	"bufio"
	"io"
	"os"
	"regexp"
	"strings"
)

type Preprocessor struct {
	Output       string
	Dependencies map[string][]string

	paths   []string
	visited map[string]bool

	definitions map[string]string
}

func NewPreprocessor(paths []string) *Preprocessor {
	return &Preprocessor{
		paths:       paths,
		definitions: map[string]string{},
		visited:     map[string]bool{},
	}
}

func (p *Preprocessor) Process() (err error) {
	var (
		file *os.File
		out  string
	)

	for _, path := range p.paths {
		file, err = os.Open(path)
		defer file.Close()

		if err != nil {
			return
		}

		out, err = p.processFile(path, file)

		if err != nil {
			return
		}

		p.Append(out)
	}

	return
}

func (p *Preprocessor) processFile(path string, input io.Reader) (buf string, err error) {
	if p.alreadyVisited(path) {
		return
	}

	p.visit(path)

	scanner := bufio.NewScanner(input)

	for scanner.Scan() {
		line := scanner.Text()

		if incPath, ok := isInclude(line); ok {
			var target *os.File
			target, err = os.Open(incPath)

			if err != nil {
				return
			}

			var processedFile string
			processedFile, err = p.processFile(incPath, target)

			if err != nil {
				return
			}

			buf += processedFile + "\n"

			continue
		}

		if ident, val, ok := isDefine(line); ok {
			p.definitions[ident] = val
			continue
		}

		buf += p.applySubstitutions(line) + "\n"
	}

	err = scanner.Err()

	return
}

func (p *Preprocessor) visit(path string) {
	p.visited[path] = true
}

func (p *Preprocessor) alreadyVisited(path string) bool {
	for visited, _ := range p.visited {
		if visited == path {
			return true
		}
	}
	return false
}

func (p *Preprocessor) applySubstitutions(line string) string {
	for key, val := range p.definitions {
		line = strings.Replace(line, key, val, -1)
	}
	return line
}

func (p *Preprocessor) Append(str string) {
	p.Output += str
}

var ire = regexp.MustCompile(`^#include\s+["'](.+)['"]$`)

func isInclude(line string) (string, bool) {
	if match := ire.FindStringSubmatch(line); len(match) > 0 {
		return match[1], true
	}
	return "", false
}

var dre = regexp.MustCompile(`^#define\s+(\S+)\s+(.+)$`)

func isDefine(line string) (string, string, bool) {
	if match := dre.FindStringSubmatch(line); len(match) > 0 {
		return match[1], match[2], true
	}
	return "", "", false
}
