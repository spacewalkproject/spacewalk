# Makefile for satellite_tool for RHNS
#
# $Id$

TOP	= ..

# Specific stuff
SUBDIR	= satellite_tools
SUBDIRS = exporter disk_dumper accounts repo_plugins
FILES	= __init__ connection constants diskImportLib messages \
            progress_bar req_channels satCerts satrm satsync syncCache \
            sync_handlers rhn-entitlement-report\
            syncLib SequenceServer xmlDiskDumper xmlDiskSource \
            xmlSource xmlWireSource rhn_satellite_activate rhn_ssl_dbstore \
            satComputePkgHeaders updatePackages reposync 

SCRIPTS = satellite-sync spacewalk-debug\
	  rhn-schema-version rhn-satellite-activate rhn-charsets \
	  rhn-ssl-dbstore update-packages rhn-db-stats rhn-schema-stats \
          spacewalk-repo-sync spacewalk-remove-channel

# check if we can build man pages
DOCBOOK = $(wildcard /usr/bin/docbook2man)

SGMLS	= $(wildcard *.sgml)
MANS	= $(patsubst %.sgml,%.8,$(SGMLS))

BINDIR	= /usr/bin
MANDIR	?= /usr/man

EXTRA_DIRS = $(MANDIR)/man8 $(BINDIR)

INSTALL_FILES   = geniso.py gentree.py
SAT_ACTIV       = rhn-satellite-activate
CA_DBSTORE      = rhn-ssl-dbstore

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

install :: $(SAT_ACTIV).inst

install :: $(CA_DBSTORE).inst

$(SAT_ACTIV).inst : $(SAT_ACTIV) $(SAT_ACTIV).new $(PREFIX)/$(BINDIR)
	$(INSTALL_BIN) $(SAT_ACTIV).new $(PREFIX)/$(BINDIR)/$(SAT_ACTIV)
	rm -f $(SAT_ACTIV).new

$(CA_DBSTORE).inst : $(CA_DBSTORE) $(CA_DBSTORE).new $(PREFIX)/$(BINDIR)
	$(INSTALL_BIN) $(CA_DBSTORE).new $(PREFIX)/$(BINDIR)/$(CA_DBSTORE)
	rm -f $(CA_DBSTORE).new


%.new : %
	sed -e 's|@@ROOT@@|$(ROOT)|g' <$* >$@

%.8 : %.sgml
	$(DOCBOOK) $<

clean ::
	@rm -fv $(MANS) manpage.* *.new

include Makefile.dump
