PROGNAME ?= mpp
SOURCES = *.go

-include config.mk

export GOPATH ?= $(PWD)/.gopath
DEPS = $(firstword $(subst :, ,$(GOPATH)))/up-to-date

$(PROGNAME): $(SOURCES) $(DEPS) version.go | $(dir $(PROGNAME))
	go build -o $(PROGNAME)

test: $(PROGNAME) $(SOURCES)
	go test

clean:
	rm -f $(PROGNAME)
	rm -f version.go
	rm -rf pkg/

install: $(PROGNAME)
	install -d $(prefix)/bin
	install -m 0755 $(PROGNAME) $(prefix)/bin

version.go: VERSION
	echo 'package main\n\nconst VERSION = "$(shell cat $<)"' > $@

release: $(PROGNAME) VERSION | pkg
	scripts/release.sh

$(DEPS): Godeps | $(dir $(DEPS))
	gpm install
	touch $@

$(dir $(DEPS)):
	mkdir -p $@

$(dir $(PROGNAME)):
	mkdir -p $@

pkg:
	mkdir $@

config.mk:
	@./configure

.PHONY: test clean install release
