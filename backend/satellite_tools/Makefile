# Makefile for satellite_tool for RHNS
#

TOP	= ..

# Specific stuff
SUBDIR	= satellite_tools
SUBDIRS = exporter disk_dumper accounts repo_plugins
SPACEWALK_FILES	= __init__ connection constants diskImportLib messages \
            progress_bar req_channels satCerts satsync syncCache \
            sync_handlers \
            syncLib SequenceServer xmlDiskSource \
            xmlSource xmlWireSource rhn_ssl_dbstore \
            satComputePkgHeaders updatePackages reposync \
	    geniso
SCRIPTS = satellite-sync spacewalk-debug \
	  rhn-schema-version rhn-charsets \
	  rhn-ssl-dbstore update-packages rhn-db-stats rhn-schema-stats \
          spacewalk-repo-sync spacewalk-remove-channel \
	  spacewalk-update-signatures spacewalk-data-fsck spacewalk-fips-tool

# check if we can build man pages
DOCBOOK = $(wildcard /usr/bin/docbook2man)

SGMLS	= $(wildcard *.sgml)
MANS	= $(patsubst %.sgml,%.8,$(SGMLS))

BINDIR	= /usr/bin
MANDIR	?= /usr/man

EXTRA_DIRS = $(MANDIR)/man8 $(BINDIR)

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

install :: $(CA_DBSTORE).inst

$(CA_DBSTORE).inst : $(CA_DBSTORE) $(CA_DBSTORE).new $(PREFIX)/$(BINDIR)
	$(INSTALL_BIN) $(CA_DBSTORE).new $(PREFIX)/$(BINDIR)/$(CA_DBSTORE)
	rm -f $(CA_DBSTORE).new


%.new : %
	sed -e 's|@@ROOT@@|$(ROOT)|g' <$* >$@

%.8 : %.sgml
	$(DOCBOOK) $<

clean ::
	@rm -fv $(MANS) manpage.* *.new

