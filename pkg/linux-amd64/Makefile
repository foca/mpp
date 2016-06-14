ARCH = $(shell basename $(PWD))
IMAGE = .docker-image-built

mpp: $(IMAGE)
	docker run --rm -e "DIST=pkg/$(ARCH)/mpp" -v "$(PWD)/../..:/mnt" crystal:$(ARCH)

.PHONY: clean
clean:
	rm -f $(IMAGE) mpp

$(IMAGE): Dockerfile
	docker build -t crystal:$(ARCH) . && touch $@
