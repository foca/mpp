TARGET  ?= bin/mpp
CRYSTAL ?= crystal
DIST    ?= dist/$(notdir $(TARGET))

DEPS = bin/mpp.cr $(shell find src -iname '*.cr')

-include config.mk
prefix ?= /usr/local

.PHONY: all
all: $(TARGET) man

.PHONY: clean
clean:
	rm -f $(TARGET) $(DIST)
	cd man && $(MAKE) clean

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

$(TARGET): $(DEPS)
	mkdir -p $(@D)
	$(CRYSTAL) build -o $@ $<

$(DIST): $(DEPS)
	mkdir -p $(@D)
	$(CRYSTAL) build --release -o $@ $<
