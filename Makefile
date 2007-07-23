# Makefile for orarep
# $Id$

DESTDIR=
prefix=/opt
BINDIR=$(DESTDIR)$(prefix)/orarep
INSTALL=

install: installdirs
	cp -pr * $(BINDIR)
	rm -f $(BINDIR)/Makefile

installdirs:
	mkdir -p $(BINDIR)

uninstall:
	rm -rf $(BINDIR)

