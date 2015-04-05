package main

import (
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

var loadPaths = []string{}

func AddTemplatePaths(paths string) (err error) {
	for _, path := range filepath.SplitList(paths) {
		if path, err = filepath.Abs(path); err != nil {
			return
		}
		loadPaths = append(loadPaths, path)
	}

	return
}

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
		if tpl != nil {
			tpl.Close()
		}
	}
}

var cache = map[string]*Template{}

type Template struct {
	file    *os.File
	path    string
	relPath string
}

func FindTemplate(path string) (tpl *Template, err error) {
	path, err = realPath(path)

	if err != nil {
		return
	}

	var ok bool
	if tpl, ok = cache[path]; ok {
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

	cache[path] = tpl

	return
}

func (tpl *Template) Path() string {
	return tpl.path
}

func (tpl *Template) Rel() string {
	return tpl.relPath
}

func (tpl *Template) Close() {
	if tpl != nil && tpl.file != nil {
		delete(cache, tpl.Path())
		tpl.file.Close()
	}
}

func (tpl *Template) Read(p []byte) (int, error) {
	return tpl.file.Read(p)
}

func realPath(path string) (string, error) {
	if filepath.IsAbs(path) {
		return path, nil
	}

	for _, dir := range loadPaths {
		test := filepath.Join(dir, path)

		if _, err := os.Stat(test); err == nil {
			return test, nil
		}
	}

	err := errors.New(
		fmt.Sprintf("Can't find file %s in %s",
			path, strings.Join(loadPaths, string(filepath.ListSeparator))))

	return "", err
}

func fileExists(path string) (bool, error) {
	_, err := os.Stat(path)

	if err == nil {
		return true, nil
	}

	if os.IsNotExist(err) {
		return false, nil
	}

	return false, err
}
