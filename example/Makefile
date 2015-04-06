.PHONY: all clean

all: css/root.css js/root.js

clean:
	rm -rf css/
	rm -rf js/
	rm -f .deps.mk

css/%.css: assets/css/%.css | css
	../mpp -Iassets/css $< > $@

js/%.js: assets/js/%.js | js
	../mpp -Iassets/js $< > $@

css:
	mkdir $@

js:
	mkdir $@

.deps.mk:
	@../mpp -Iassets/css:assets/js -M assets/**/*.* > $@

-include .deps.mk
