export GEM_HOME := .deps
export GEM_PATH := $(GEM_HOME):$(GEM_PATH)
export PATH := $(GEM_HOME)/bin:$(PATH)

DEPS := $(GEM_HOME)/installed

.PHONY: all
all: mpp.1

.PHONY: clean
clean:
	rm -f mpp.1 mpp.html

%.1: %.1.ronn $(DEPS)
	ronn --roff --pipe --manual="User Manual" $< > $@

$(DEPS):
	mkdir -p $(@D)
	gem install ronn
	touch $@
