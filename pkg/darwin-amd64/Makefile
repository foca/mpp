ARCH = $(shell basename $(PWD))
PACKAGE = mpp-$(VERSION)_$(ARCH).tar.gz

.PHONY: all
all: $(PACKAGE)

.PHONY: clean
clean:
	rm -f $(PACKAGE) mpp

$(PACKAGE): mpp
	tar -czf $@ $< -C ../_support .

mpp:
	cd ../..; $(MAKE) DIST=pkg/$(ARCH)/mpp dist
