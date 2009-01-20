# Makefile for the apacheServer.py for RHN Proxy misc tools.
#
# $Id: Makefile,v 1.6 2004/10/17 22:37:08 taw Exp $

TOP	= ..
SUBDIR	= proxy/tools

FILES = __init__  

SCRIPTS =  

SERVICE_SCRIPTS = rhn-proxy

# check if we can build man pages
DOCBOOK = $(wildcard /usr/bin/docbook2man)

SGMLS	= $(wildcard *.sgml)
MANS	= $(patsubst %.sgml,%.8,$(SGMLS))

BINDIR	= /usr/bin
INITDIR = /etc/rc.d/init.d
MANDIR	?= /usr/share/man

EXTRA_DIRS = $(MANDIR)/man8 $(BINDIR) $(INITDIR)

include $(TOP)/Makefile.defs

# install scripts
all :: $(SCRIPTS)
install :: $(SCRIPTS) $(PREFIX)/$(BINDIR)
	$(INSTALL_BIN) $(SCRIPTS) $(PREFIX)/$(BINDIR)

# install service scripts
all :: $(SERVICE_SCRIPTS)
install :: $(SERVICE_SCRIPTS) $(PREFIX)/$(INITDIR)
	$(INSTALL_BIN) $(SERVICE_SCRIPTS) $(PREFIX)/$(INITDIR)

ifneq ($(DOCBOOK),)
# install man pages
all	:: $(MANS)
install :: $(MANS) $(PREFIX)/$(MANDIR)
	$(INSTALL_DATA) $(MANS) $(PREFIX)/$(MANDIR)/man8
endif

%.8 : %.sgml
	/usr/bin/docbook2man $<

clean ::
	@rm -fv $(MANS) manpage.*


