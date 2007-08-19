# Makefile for orarep
# $Id$

DESTDIR=
prefix=/usr/local
BINDIR=$(DESTDIR)$(prefix)/share/orarep
datadir=$(BINDIR)/reports
INSTALL=

WEBROOT=$(DESTDIR)/var/www
LINKTO=$(WEBROOT)/orarep

install: installdirs
	cp -pr * $(BINDIR)
	rm -f $(BINDIR)/Makefile
	if [ ! -e $(LINKTO) ]; then ln -s $(datadir) $(LINKTO); fi

installdirs:
	if [ ! -d $(WEBROOT) ]; then mkdir -p $(WEBROOT); fi
	mkdir -p $(BINDIR)

uninstall:
	rm -rf $(BINDIR)
	linkstat=`readlink $(LINKTO)`
	if [ "$linkstat" = "$(datadir)" ]; then rm -f $(LINKTO); fi

