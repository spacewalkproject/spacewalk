TOP	= ..

# Specific stuff
SUBDIR	= cdn_tools
SUBDIRS = 
SPACEWALK_FILES	= __init__  constants  manifest \
            activation cdnsync
SCRIPTS = cdn-sync

# check if we can build man pages
DOCBOOK = $(wildcard /usr/bin/docbook2man)

SGMLS	= $(wildcard *.sgml)
MANS	= $(patsubst %.sgml,%.8,$(SGMLS))

BINDIR	= /usr/bin
MANDIR	?= /usr/man

EXTRA_DIRS = $(MANDIR)/man8 $(BINDIR)

include $(TOP)/Makefile.defs

# install scripts
all :: $(SCRIPTS)
install :: $(SCRIPTS) $(PREFIX)/$(BINDIR)
	$(INSTALL_BIN) $(SCRIPTS) $(PREFIX)/$(BINDIR)

ifneq ($(DOCBOOK),)
# install man pages
all	:: $(MANS)
install :: $(MANS) $(PREFIX)/$(MANDIR)
	$(INSTALL_DATA) $(MANS) $(PREFIX)/$(MANDIR)/man8
endif


%.new : %
	sed -e 's|@@ROOT@@|$(ROOT)|g' <$* >$@

%.8 : %.sgml
	$(DOCBOOK) $<

clean ::
	@rm -fv $(MANS) manpage.* *.new

