# Makefile for Update Agent
#
# $Id: Makefile,v 1.23 2004/10/11 20:08:15 alikins Exp $

# This is bogus - this directory should depend on the OS.  But,
# libiberty includes getopt_long for each platform, so we'll just use
# one include directory.
GETOPT_INCLUDE	= -I/opt/redhat/gnupro-03r1-3/sources/tools/native/include
GETOPT_LIB	= -liberty

OS		:= $(shell uname -s)

DESTPREFIX	= /

ifeq ("$(OS)", "SunOS")
# Solaris has gettext
DESTPREFIX	= /opt/redhat/rhn/solaris
endif

ifeq ("$(OS)", "HP-UX")
# HP-UX has no gettext
DESTPREFIX	= /opt/redhat/rhn/hpux
GETOPT_INCLUDE	+= -D_NO_GETTEXT
endif

ifeq ("$(OS)", "AIX")
# AIX has no gettext
DESTPREFIX	= /opt/redhat/rhn/aix
GETOPT_INCLUDE	+= -D_NO_GETTEXT
endif

ifndef DESTPREFIX
$(error Unknown OS "$(OS)")
endif

PREFIX		?=
SUBPATH	        = /usr
MANPATH		?= /usr/share/man

RHN_CHECK       = rhn_check
RHNSD           = rhnsd
RHNSD_CONFIG	= rhnsd.sysconfig
RHNSD_INIT	= rhnsd.init

OBJECTS		= $(RHNSD) 


# Directories for installation
CONFIG_DIR	= $(PREFIX)/etc/sysconfig/rhn
DEST_CONFIG_DIR = $(DESTPREFIX)/etc/sysconfig/rhn
CAPS_DIR	= $(PREFIX)/etc/sysconfig/rhn/clientCaps.d
RHNSHARE_DIR	= $(PREFIX)/$(SUBPATH)/share/rhn
CLIENT_DIR	= $(RHNSHARE_DIR)/$(CLIENT_DIR_NAME)
BIN_DIR		= $(PREFIX)/$(SUBPATH)/bin
SBIN_DIR	= $(PREFIX)/$(SUBPATH)/sbin
DEST_SBIN_DIR	= $(DESTPREFIX)/$(SUBPATH)/sbin
PIXMAP_DIR	= $(PREFIX)/$(SUBPATH)/share/pixmaps
LIBDIR		= $(PREFIX)/$(SUBPATH)/lib/
PID_DIR		= $(PREFIX)/var/run
INITD_DIR	= $(PREFIX)/etc/init.d

# all dirs
DIRS		= $(CONFIG_DIR) \
		  $(RHNSHARE_DIR) $(CLIENT_DIR) \
		  $(PYTHONMOD_DIR)\
		  $(BIN_DIR) $(SBIN_DIR) $(PIXMAP_DIR) \
		  $(CAPS_DIR) $(PID_DIR) $(INITD_DIR)



DEST_RHN_CHECK_PATH 	= $(DEST_SBIN_DIR)/$(RHN_CHECK)
RHN_SYSID	= $(DEST_CONFIG_DIR)/systemid
DESTPID_DIR	= $(DESTPREFIX)/var/run/
PID_FILE	= $(DESTPID_DIR)/rhnsd.pid


# Compilation stuff
CC		= gcc
DEFINES		= -DRHN_SYSID=\"$(RHN_SYSID)\" -DRHN_CHECK=\"$(DEST_RHN_CHECK_PATH)\" -DPATH_RHNDPID=\"$(PID_FILE)\"
CFLAGS		= $(DEFINES) -Wall -O2 -fomit-frame-pointer $(GETOPT_INCLUDE) -I/usr/local/include

LDFLAGS		= $(GETOPT_LIB)


# For subdirs, required exports 
export PREFIX 
export MANPATH
export SUBPATH

all:: $(OBJECTS)

$(RHNSD): $(RHNSD).o
	$(CC) -o $@ $< $(LDFLAGS)
%.o : %.c
	$(CC) -fPIC $(CFLAGS) -c -o $@ $<
%.so : %.o
	$(CC) -shared -Wl,-soname,$@ $< -o $@

clean::
	@rm -f *~ .*~ $(RHNSD) *.o *.so
