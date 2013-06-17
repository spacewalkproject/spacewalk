# Makefile for spacewalk backend
#
# $Id$

# what is the backend top dir
TOP     = ..

# Specific stuff
SUBDIR		= config_management
EXEC_FILES	= rhncfg-manager
FILES           = $(EXEC_FILES) __init__ \
                  rhncfg_add \
                  rhncfg_create_channel \
                  rhncfg_diff \
                  rhncfg_diff_revisions \
                  rhncfg_download_channel \
                  rhncfg_get \
                  rhncfg_list \
                  rhncfg_list_channels \
                  rhncfg_remove \
                  rhncfg_remove_channel \
                  rhncfg_revisions \
                  rhncfg_update \
                  rhncfg_upload_channel \
                  rpc_repository
CONFIG_FILES    = rhncfg-manager.conf

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
