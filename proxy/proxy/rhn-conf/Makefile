# Makefile for installation of the Red Hat Proxy configuration files
#
# $Id: Makefile,v 1.2 2002/08/20 22:40:05 misa Exp $

# what is the backend top dir
TOP	= ..

INSTALL_FILES	= $(wildcard *.conf)
INSTALL_DEST	= /usr/share/rhn/config-defaults

include $(TOP)/Makefile.defs

install :: $(PREFIX)$(INSTALL_DEST)
	mkdir -p $(PREFIX)/etc/rhn
	touch $(PREFIX)/etc/rhn/rhn.conf
