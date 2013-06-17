# Makefile for installation of the Red Hat Proxy configuration files
#

# what is the backend top dir
TOP	= ..

INSTALL_FILES	= $(wildcard *.conf)
INSTALL_DEST	= /usr/share/rhn/config-defaults

include $(TOP)/Makefile.defs

install :: $(PREFIX)$(INSTALL_DEST)
	mkdir -p $(PREFIX)/etc/rhn
	touch $(PREFIX)/etc/rhn/rhn.conf
