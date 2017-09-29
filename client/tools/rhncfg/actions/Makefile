# Makefile for spacewalk backend
#

# what is the backend top dir
TOP     = ..

# Specific stuff
SUBDIR		= rhn/actions
EXEC_FILES      = rhn-actions-control
FILES           = $(EXEC_FILES) configfiles script \
                  Modes ModeController ModeControllerCreator
CAPS		= configfiles script
CAPS_DIR	= /etc/sysconfig/rhn/clientCaps.d

#man page stuff
DOCBOOK = $(wildcard /usr/bin/docbook2man)
                                                                                                                                                                                   
SGMLS   = $(wildcard *.sgml)
MANS    = $(patsubst %.sgml,%.8,$(SGMLS))
MANDIR  ?= /usr/man


EXTRA_DIRS	= $(MANDIR)/man8 $(BINDIR) $(CAPS_DIR)

include $(TOP)/Makefile.defs

install :: install-bin install-caps

install-caps :: $(CAPS) $(PREFIX)$(CAPS_DIR)
	$(INSTALL_DATA) $(CAPS) $(PREFIX)$(CAPS_DIR)

ifneq ($(DOCBOOK),)
# install man pages
all :: $(MANS)
install :: $(MANS) $(PREFIX)$(MANDIR)
	$(INSTALL_DATA) $(MANS) $(PREFIX)$(MANDIR)/man8
endif

clean ::
	@rm -fv $(MANS) manpage.*

