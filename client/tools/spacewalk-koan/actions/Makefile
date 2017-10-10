# Makefile for the backend directory
#

TOP         = ..
ROOT        = /usr/share/rhn
SUBDIR      = rhn/actions
FILES       = kickstart
CAPS        = kickstart
CAPS_DIR    = /etc/sysconfig/rhn/clientCaps.d
EXTRA_DIRS  = $(CAPS_DIR)

VIRT_FILES = kickstart_guest

# now include some Macros
include $(TOP)/Makefile.defs

install :: install-caps

install-caps :: $(CAPS) $(PREFIX)$(CAPS_DIR)
	$(INSTALL_DATA) $(CAPS) $(PREFIX)$(CAPS_DIR)
