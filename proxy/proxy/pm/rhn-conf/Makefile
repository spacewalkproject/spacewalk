# Makefile for installation of the RHN Package Manager configuration files
#
# $Id: Makefile,v 1.1 2002/08/20 22:40:42 misa Exp $

# what is the backend top dir
TOP	= ../..

INSTALL_FILES	= $(wildcard *.conf)
INSTALL_DEST	= /etc/rhn/default

include $(TOP)/Makefile.defs

install :: $(PREFIX)$(INSTALL_DEST)
	touch $(PREFIX)$(INSTALL_DEST)/../rhn.conf
