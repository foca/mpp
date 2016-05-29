.PHONY: all clean

MPP = ../bin/mpp -Iassets/css -Iassets/js

all: css/root.css js/root.js

clean:
	rm -rf css/
	rm -rf js/
	rm -f .deps.mk

css/%.css: assets/css/%.css | css
	$(MPP) $< > $@

js/%.js: assets/js/%.js | js
	$(MPP) $< > $@

css:
	mkdir $@

js:
	mkdir $@

ASSETS = $(shell find assets -type f)

.deps.mk: $(ASSETS)
	@$(MPP) -M $^ > $@

-include .deps.mk
