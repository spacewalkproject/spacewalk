# Makefile for registration server for RHNS
#
# $Id$

# what is the backend top dir
TOP     = ..

# Specific stuff
SUBDIR  = common
FILES	=   __init__ \
            rhn_fcntl \
            rhn_mpm \
            rhn_posix \
            rhn_rpm \
            rhn_timer \
            rhnApache \
            rhnCache \
            rhnConfig \
            rhnException \
            rhnFlags \
            rhnLib \
            rhnLockfile \
            rhnLog \
            rhnMail \
            rhnRepository \
            rhnTB \
            rhnTranslate \
            RPC_Base \
            UserDictCase
SCRIPTS = spacewalk-cfg-get

BINDIR  = /usr/bin

EXTRA_DIRS = $(BINDIR)

include $(TOP)/Makefile.defs

# install scripts
all :: $(SCRIPTS)
install :: $(SCRIPTS) $(PREFIX)/$(BINDIR)
	$(INSTALL_BIN) $(SCRIPTS) $(PREFIX)/$(BINDIR)

