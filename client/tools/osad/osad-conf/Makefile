# Makefile for installation of the RHN server configuration files
#

# what is the backend top dir
TOP	= ..

INSTALL_FILES	= $(wildcard *.conf)
INSTALL_DEST	= /etc/sysconfig/rhn

CAPS            = osad
CAPS_DIR        = /etc/sysconfig/rhn/clientCaps.d
EXTRA_DIRS      = $(CAPS_DIR)

include $(TOP)/Makefile.defs

install :: install-caps

install-caps :: $(CAPS) $(PREFIX)$(CAPS_DIR)
	$(INSTALL_DATA) $(CAPS) $(PREFIX)$(CAPS_DIR)
