ARCH = $(shell basename $(PWD))
IMAGE = .docker-image-built
PACKAGE = mpp-$(VERSION)_$(ARCH).tar.gz

.PHONY: all
all: $(PACKAGE)

.PHONY: clean
clean:
	rm -f $(IMAGE) $(PACKAGE) mpp

$(PACKAGE): mpp
	tar -czf $@ $< -C ../_support .

mpp: $(IMAGE)
	docker run --rm -e "DIST=pkg/$(ARCH)/mpp" -v "$(PWD)/../..:/mnt" crystal:$(ARCH)

$(IMAGE): Dockerfile
	docker build -t crystal:$(ARCH) . && touch $@
