ARCH = $(shell basename $(PWD))

mpp:
	cd ../..; $(MAKE) DIST=pkg/$(ARCH)/mpp dist

.PHONY: clean
clean:
	rm -f mpp
