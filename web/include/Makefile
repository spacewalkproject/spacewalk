# Makefile for installing the html files for RHN
#
# $Id$

TOP = ..

# Project defines
INSTALL_DEST	= /usr/share/spacewalk/web

# common stuff
include $(TOP)/Makefile.defs

# exclude these files from instalation
NO_INSTALL	= Makefile

all::

install:: $(PREFIX)/$(INSTALL_DEST)
	tar cpf - $(addprefix --exclude ,$(NO_INSTALL)) . | \
	    tar vxf - -C $(PREFIX)$(INSTALL_DEST)
