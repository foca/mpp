PROGNAME ?= bin/mpp
SOURCES = *.go

-include config.mk

export GOPATH ?= $(PWD)/.gopath
DEPS = $(firstword $(subst :, ,$(GOPATH)))/up-to-date
export PATH := $(dir $(DEPS))/bin:$(PATH)

all: $(PROGNAME) manual

$(PROGNAME): $(SOURCES) $(DEPS) version.go | $(dir $(PROGNAME))
	go build -o $(PROGNAME)

test: $(PROGNAME) $(SOURCES)
	go test

clean:
	rm -f $(PROGNAME)
	rm -f version.go
	rm -rf pkg/
	rm -f man/*.{1,html}

install: $(PROGNAME) man/$(notdir $(PROGNAME)).1
	install -d $(prefix)/bin
	install -m 0755 $(PROGNAME) $(prefix)/bin
	install -d $(prefix)/share/man/man1
	install man/$(notdir $(PROGNAME)).1 $(prefix)/share/man/man1

uninstall:
	rm -f $(prefix)/bin/$(notdir $(PROGNAME))
	rm -f $(prefix)/share/man/man1/$(notdir $(PROGNAME)).1

version.go: VERSION
	echo 'package main\n\nconst VERSION = "$(shell cat $<)"' > $@

release: $(PROGNAME) VERSION manual | pkg $(dir $(DEPS))/bin/gox
	scripts/release.sh

manual: man/mpp.1 man/mpp.html

ifneq (mpp,$(notdir $(PROGNAME)))
# Make sure that the manual page installed by `make install` has the same name
# as the generated binary.
man/$(notdir $(PROGNAME)).%: man/mpp.%
	cp -f $< $@
endif

man/%.1: man/%.1.ronn
	ronn --roff --pipe --manual="User Manual" $< > $@

man/%.html: man/%.1.ronn
	ronn --html --pipe --manual="User Manual" $< > $@

$(DEPS): Godeps | $(dir $(DEPS))
	gpm install
	touch $@

$(dir $(DEPS)) $(dir $(PROGNAME)) pkg:
	mkdir -p $@

config.mk:
	@./configure

# Make sure we have gox locally available for cross-compilation
$(dir $(DEPS))/bin/gox:
	go get github.com/mitchellh/gox
	PATH=$(PATH) gox -build-toolchain

.PHONY: all test clean install uninstall release manual
