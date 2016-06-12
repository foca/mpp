TARGET  ?= bin/mpp
CRYSTAL ?= crystal
DIST    ?= dist/$(notdir $(TARGET))
VERSION = $(shell sed -ne '/.*version: *\(.*\)$$/s//\1/p' <shard.yml)

DEPS = src/mpp.cr $(shell find src -iname '*.cr' -not -name 'mpp.cr') src/version.cr

-include config.mk
prefix ?= /usr/local

.PHONY: all
all: $(TARGET) man/mpp.1

.PHONY: test
test: $(DEPS)
	crystal spec

.PHONY: clean
clean:
	rm -f $(TARGET) $(DIST) src/version.cr
	cd man && $(MAKE) clean
	cd example && $(MAKE) clean

.PHONY: dist
dist: $(DIST)

.PHONY: man
man:
	cd man && $(MAKE)

.PHONY: install
install: $(DIST) man/mpp.1
	install -d $(prefix)/bin $(prefix)/share/man/man1
	install -m 0755 $(DIST) $(prefix)/bin
	install man/mpp.1 $(prefix)/share/man/man1

.PHONY: uninstall
uninstall:
	rm -f $(prefix)/bin/mpp
	rm -f $(prefix)/share/man/man1/mpp.1

.PHONY: example
example: $(TARGET)
	cd example; $(MAKE)

src/version.cr: shard.yml
	echo 'MPP_VERSION = "$(VERSION)"' > $@

man/mpp.1:
	cd man && $(MAKE) mpp.1

$(TARGET): $(DEPS) src/version.cr | $(dir $(TARGET))
	$(CRYSTAL) build -o $@ $<

$(DIST): $(DEPS) | $(dir $(DIST))
	$(CRYSTAL) build --release -o $@ $<

bin dist:
	mkdir -p $@
