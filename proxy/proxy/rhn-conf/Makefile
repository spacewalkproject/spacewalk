# Makefile for installation of the RHN proxy configuration files
#
# $Id: Makefile,v 1.2 2002/08/20 22:40:05 misa Exp $

# what is the backend top dir
TOP	= ..

INSTALL_FILES	= $(wildcard *.conf)
INSTALL_DEST	= /etc/rhn/default

include $(TOP)/Makefile.defs

install :: $(PREFIX)$(INSTALL_DEST)
	touch $(PREFIX)$(INSTALL_DEST)/../rhn.conf
