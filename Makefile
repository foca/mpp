PROGNAME ?= mpp
SOURCES = *.go
DEPS = $(firstword $(subst :, ,$(GOPATH)))/up-to-date

$(PROGNAME): $(SOURCES) $(DEPS) version.go | $(dir $(PROGNAME))
	go build -o $(PROGNAME)

test: $(PROGNAME) $(SOURCES)
	go test

clean:
	rm -f $(PROGNAME)
	rm -f version.go

version.go: VERSION
	echo 'package main\n\nconst VERSION = "$(shell cat $<)"' > $@

$(DEPS): Godeps | $(dir $(DEPS))
	gpm install
	touch $@

$(dir $(DEPS)):
	mkdir -p $@

$(dir $(PROGNAME)):
	mkdir -p $@

.PHONY: test clean
