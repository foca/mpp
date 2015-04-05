package main

import (
	"os"
	"path/filepath"
)

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
