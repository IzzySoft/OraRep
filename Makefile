# Makefile for orarep
# $Id$

DESTDIR=
BINDIR=$(DESTDIR)/opt/orarep
INSTALL=

install: installdirs
	cp -pr * $(BINDIR)
	rm -f $(BINDIR)/Makefile

installdirs:
	mkdir -p $(BINDIR)

uninstall:
	rm -rf $(BINDIR)

