package main

import (
	"os"
	"path/filepath"
)

type TemplateList []*Template

func FindAllTemplates(paths []string) (tpls TemplateList, err error) {
	tpls = make(TemplateList, len(paths))

	var tpl *Template
	for i, path := range paths {
		tpl, err = FindTemplate(path)

		if err != nil {
			return
		}

		tpls[i] = tpl
	}

	return
}

func (tpls TemplateList) Close() {
	for _, tpl := range tpls {
		tpl.Close()
	}
}

type Template struct {
	file    *os.File
	path    string
	relPath string
}

func FindTemplate(path string) (tpl *Template, err error) {
	path, err = filepath.Abs(path)

	if err != nil {
		return
	}

	relPath, err := filepath.Rel(CWD, path)

	if err != nil {
		return
	}

	var file *os.File
	file, err = os.Open(path)

	if err != nil {
		return
	}

	tpl = &Template{file: file, path: path, relPath: relPath}

	return
}

func (tpl *Template) Path() string {
	return tpl.path
}

func (tpl *Template) Rel() string {
	return tpl.relPath
}

func (tpl *Template) Close() {
	tpl.file.Close()
}

func (tpl *Template) Read(p []byte) (int, error) {
	return tpl.file.Read(p)
}
