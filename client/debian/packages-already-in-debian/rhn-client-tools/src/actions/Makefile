# Makefile for installing man pages for the up2date client
#
# $Id$

ACTIONS		= up2date_config hardware reboot \
		  rhnsd systemid __init__
PYFILES		= $(addsuffix .py, $(ACTIONS))
OBJECTS		= $(PYFILES) $(addsuffix .pyc, $(ACTIONS))

# Install stuff
INSTALL         = /usr/bin/install -c
INSTALL_BIN     = $(INSTALL) -m 755
INSTALL_DIR     = $(INSTALL) -m 755 --verbose -d

# Install Directories
RHNSHARE_DIR    = $(PREFIX)/usr/share/rhn
ACTIONDIR	= $(RHNSHARE_DIR)/actions


PYCHECKER       = /usr/bin/pychecker

all:: $(OBJECTS)

# default compile rule:
%.pyc: %.py
	python -c "import py_compile; py_compile.compile('$<')"

install: all $(ACTIONDIR)
	$(INSTALL_BIN) $(OBJECTS) $(ACTIONDIR)/ 

$(ACTIONDIR) : 
	@$(INSTALL_DIR) $@

clean:
	@rm -rf *.pyc *~ .*~ *.o

pychecker::
	@$(PYCHECKER) $(PYFILES) || exit 0

