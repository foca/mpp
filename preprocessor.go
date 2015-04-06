package main

import (
	"bufio"
	"fmt"
	"regexp"
	"strings"
)

type Preprocessor struct {
	Output string

	paths   []string
	visited map[*Template]bool

	definitions map[string]string
}

func NewPreprocessor(paths []string) *Preprocessor {
	return &Preprocessor{
		paths:       paths,
		definitions: map[string]string{},
		visited:     map[*Template]bool{},
	}
}

func (p *Preprocessor) Process() (err error) {
	templates, err := FindAllTemplates(p.paths)
	defer templates.Close()

	if err != nil {
		return
	}

	var out string
	for _, template := range templates {
		if out, err = p.processTemplate(template); err != nil {
			return
		}
		p.Output += out
	}

	return
}

func (p *Preprocessor) processTemplate(tpl *Template) (buf string, err error) {
	//  Don't process a file more than once
	if _, ok := p.visited[tpl]; ok {
		return
	}
	p.visited[tpl] = true

	scanner := bufio.NewScanner(tpl)

	for scanner.Scan() {
		line := scanner.Text()

		var inc *Template
		if incPath, ok := isInclude(line); ok {
			inc, err = FindTemplate(incPath)
			defer inc.Close()

			if err != nil {
				return
			}

			var processedFile string
			processedFile, err = p.processTemplate(inc)

			if err != nil {
				return
			}

			tpl.AddDependency(inc)

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

func (p *Preprocessor) applySubstitutions(line string) string {
	for key, val := range p.definitions {
		line = strings.Replace(line, key, val, -1)
	}
	return line
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

func (p *Preprocessor) MakefileDependencies() string {
	rules := []string{}

	for tpl := range p.visited {
		if len(tpl.Dependencies()) > 0 {
			deps := strings.Join(tpl.Dependencies(), " ")
			rule := fmt.Sprintf("%s: %s\n\t@touch $@", tpl.Rel(), deps)
			rules = append(rules, rule)
		}
	}

	// Make sure the last rule is properly formatted with a newline at the end
	if len(rules) > 0 {
		rules = append(rules, "")
	}

	return strings.Join(rules, "\n\n")
}
