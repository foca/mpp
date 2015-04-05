PROGNAME ?= mpp
SOURCES = *.go
DEPS = $(firstword $(subst :, ,$(GOPATH)))/up-to-date

$(PROGNAME): $(SOURCES) $(DEPS) | $(dir $(PROGNAME))
	go build -o $(PROGNAME)

test: $(PROGNAME) $(SOURCES)
	go test

clean:
	rm -f $(PROGNAME)

$(DEPS): Godeps | $(dir $(DEPS))
	gpm install
	touch $@

$(dir $(DEPS)):
	mkdir -p $@

$(dir $(PROGNAME)):
	mkdir -p $@

.PHONY: test clean
