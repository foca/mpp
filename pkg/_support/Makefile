-include config.mk
prefix ?= /usr/local

install:
	install -d $(prefix)/bin $(prefix)/share/man/man1
	install -m 0755 mpp $(prefix)/bin
	install man/mpp.1 $(prefix)/share/man/man1

uninstall:
	rm -f $(prefix)/bin/mpp
	rm -f $(prefix)/share/man/man1/mpp.1
