TARGET  ?= bin/mpp
CRYSTAL ?= crystal
DIST    ?= dist/$(notdir $(TARGET))

DEPS = bin/mpp.cr $(shell find src -iname '*.cr')

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

$(TARGET): $(DEPS)
	mkdir -p $(@D)
	$(CRYSTAL) build -o $@ $<

$(DIST): $(DEPS)
	mkdir -p $(@D)
	$(CRYSTAL) build --release -o $@ $<
