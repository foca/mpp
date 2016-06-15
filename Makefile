TARGET  ?= bin/mpp
CRYSTAL ?= crystal
DIST    ?= dist/$(notdir $(TARGET))
export VERSION = $(shell sed -ne '/.*version: *\(.*\)$$/s//\1/p' <shard.yml)

DEPS = src/mpp.cr $(shell find src -iname '*.cr' -not -name 'mpp.cr') src/version.cr

# The architectures we want to build packages for
DIST_TARGETS = $(shell find pkg -type d -depth 1 -not -name _support)
PACKAGES = $(addprefix pkg/mpp-$(VERSION)_,$(addsuffix .tar.gz,$(notdir $(DIST_TARGETS))))

-include config.mk
prefix ?= /usr/local

.PHONY: all
all: $(TARGET) man/mpp.1

.PHONY: test
test: $(DEPS)
	crystal spec

.PHONY: clean
clean:
	rm -f $(TARGET) $(DIST) src/version.cr pkg/*/mpp
	cd man && $(MAKE) clean
	cd example && $(MAKE) clean
	rm -f pkg/_support/{configure,mpp.1} pkg/*.tar.gz
	for arch in $(DIST_TARGETS); do (cd $$arch; $(MAKE) clean); done

.PHONY: dist
dist: $(DIST)

.PHONY: man
man: man/mpp.1

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

.PHONY: pkg
pkg: $(PACKAGES)

.PHONY: release
release: $(PACKAGES)
	git push origin master
	script/release foca/mpp v$(VERSION) -- $(PACKAGES)

src/version.cr: shard.yml
	echo 'MPP_VERSION = "$(VERSION)"' > $@

man/mpp.1:
	cd $(@D); $(MAKE) $(@F)

$(TARGET): $(DEPS) src/version.cr | $(dir $(TARGET))
	$(CRYSTAL) compile -o $@ $<

$(DIST): $(DEPS) | $(dir $(DIST))
	$(CRYSTAL) compile --release -o $@ $<

mpp-$(VERSION)_%.tar.gz: pkg/_support/mpp.1 pkg/_support/configure
	cd $*; $(MAKE) mpp
	tar -czf $*/$(@F) -C $* mpp -C ../_support .
	mv $*/$(@F) $@

pkg/_support/configure: configure
	cp $< $@

pkg/_support/mpp.1: man/mpp.1
	cp $< $@

bin dist pkg/_support:
	mkdir -p $@
