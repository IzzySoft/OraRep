# Makefile for orarep
# $Id$

DESTDIR=
prefix=/usr/local
BINDIR=$(DESTDIR)$(prefix)/orarep
INSTALL=

install: installdirs
	cp -pr * $(BINDIR)
	rm -f $(BINDIR)/Makefile

installdirs:
	mkdir -p $(BINDIR)

uninstall:
	rm -rf $(BINDIR)

