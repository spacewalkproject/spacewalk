# Makefile for registration server for RHNS
#
# $Id$

# what is the backend top dir
TOP     = ..

# Specific stuff
SUBDIR		= config_client
EXEC_FILES	= rhncfg-client
FILES           = $(EXEC_FILES) __init__ handler_base \
                  rhncfgcli_channels \
                  rhncfgcli_diff rhncfgcli_get \
                  rhncfgcli_list \
                  rhncfgcli_elist \
                  rhncfgcli_verify rpc_cli_repository
CONFIG_FILES    = rhncfg-client.conf

# man pages
DOCBOOK = $(wildcard /usr/bin/docbook2man)
SGMLS	= $(wildcard *.sgml)
MANS	= $(patsubst %.sgml,%.8,$(SGMLS))
MANDIR	?= /usr/man

EXTRA_DIRS	= $(BINDIR) $(CONFDIR) $(MANDIR)/man8

include $(TOP)/Makefile.defs

ifneq ($(DOCBOOK),)
# install man pages
all	:: $(MANS)
install :: $(MANS) $(PREFIX)/$(MANDIR)
	$(INSTALL_DATA) $(MANS) $(PREFIX)/$(MANDIR)/man8
clean   ::
	@rm -fv $(MANS) manpage.*
endif

install	:: install-bin install-conf

