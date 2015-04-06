PROGNAME ?= bin/mpp
SOURCES = src/*.go

-include config.mk

export GOPATH ?= $(PWD)/.gopath
DEPS = $(firstword $(subst :, ,$(GOPATH)))/up-to-date

$(PROGNAME): $(SOURCES) $(DEPS) src/version.go | $(dir $(PROGNAME))
	cd src/; go build -o ../$(PROGNAME)

test: $(PROGNAME) $(SOURCES)
	cd src/; go test

clean:
	rm -f $(PROGNAME)
	rm -f src/version.go
	rm -rf pkg/

install: $(PROGNAME)
	install -d $(prefix)/bin
	install -m 0755 $(PROGNAME) $(prefix)/bin

uninstall:
	rm -f $(prefix)/bin/$(PROGNAME)

src/version.go: VERSION
	echo 'package main\n\nconst VERSION = "$(shell cat $<)"' > $@

release: $(PROGNAME) VERSION | pkg
	scripts/release.sh

$(DEPS): Godeps | $(dir $(DEPS))
	gpm install
	touch $@

$(dir $(DEPS)) $(dir $(PROGNAME)) pkg:
	mkdir -p $@

config.mk:
	@./configure

.PHONY: test clean install uninstall release
