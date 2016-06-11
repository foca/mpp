TARGET  ?= bin/mpp
CRYSTAL ?= crystal
DIST    ?= dist/$(notdir $(TARGET))

DEPS = src/mpp.cr $(shell find src -iname '*.cr' -not -name 'mpp.cr')

-include config.mk
prefix ?= /usr/local

.PHONY: all
all: $(TARGET) man

.PHONY: test
test:
	crystal spec

.PHONY: clean
clean:
	rm -f $(TARGET) $(DIST)
	cd man && $(MAKE) clean
	cd example && $(MAKE) clean

.PHONY: dist
dist: $(DIST)

.PHONY: man
man:
	cd man && $(MAKE)

.PHONY: install
install: $(DIST) man
	install -d $(prefix)/bin $(prefix)/share/man/man1
	install -m 0755 $(DIST) $(prefix)/bin
	install man/$(notdir $(DIST)).1 $(prefix)/share/man/man1

.PHONY: uninstall
uninstall:
	rm -f $(prefix)/bin/$(notdir $(DIST))
	rm -f $(prefix)/share/man/man1/$(notdir $(DIST)).1

.PHONY: example
example: $(TARGET)
	cd example; $(MAKE)

$(TARGET): $(DEPS)
	mkdir -p $(@D)
	$(CRYSTAL) build -o $@ $<

$(DIST): $(DEPS)
	mkdir -p $(@D)
	$(CRYSTAL) build --release -o $@ $<
