TARGET  ?= bin/mpp
CRYSTAL ?= crystal
DIST    ?= dist/$(notdir $(TARGET))

DEPS = bin/mpp.cr $(shell find src -iname '*.cr')

.PHONY: all
all: $(TARGET)

.PHONY: clean
clean:
	rm -f $(TARGET) $(DIST)

.PHONY: dist
dist: $(DIST)

$(TARGET): $(DEPS)
	mkdir -p $(@D)
	$(CRYSTAL) build -o $@ $<

$(DIST): $(DEPS)
	mkdir -p $(@D)
	$(CRYSTAL) build --release -o $@ $<
