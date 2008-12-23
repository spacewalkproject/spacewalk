# Makefile for the backend directory
#
# $Id$

TOP         = ..
ROOT        = /usr/share/rhn
SUBDIR      = actions
FILES       = kickstart, kickstart_guest
CAPS        = kickstart
CAPS_DIR    = /etc/sysconfig/rhn/clientCaps.d
EXTRA_DIRS  = $(CAPS_DIR)

# now include some Macros
include $(TOP)/Makefile.defs

install :: install-caps

install-caps :: $(CAPS) $(PREFIX)$(CAPS_DIR)
	$(INSTALL_DATA) $(CAPS) $(PREFIX)$(CAPS_DIR)
