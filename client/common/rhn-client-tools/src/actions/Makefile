# Makefile for installing man pages for the up2date client
#

ACTIONS		= up2date_config hardware reboot \
		  rhnsd systemid __init__
PYFILES		= $(addsuffix .py, $(ACTIONS))
OBJECTS		= $(PYFILES)

# Install stuff
INSTALL         = /usr/bin/install -c
INSTALL_BIN     = $(INSTALL) -m 755
INSTALL_DIR     = $(INSTALL) -m 755 --verbose -d

# Install Directories
PYTHON_DIR      = $(PREFIX)$(PYTHONPATH)
ACTIONDIR	= $(PYTHON_DIR)/rhn/actions


PYCHECKER       = /usr/bin/pychecker

all:: $(OBJECTS)

install: all $(ACTIONDIR)
	$(INSTALL_BIN) $(OBJECTS) $(ACTIONDIR)/ 

$(ACTIONDIR) : 
	$(INSTALL_DIR) $@

clean:
	@rm -rf *.pyc *~ .*~ *.o

pychecker::
	@$(PYCHECKER) $(PYFILES) || exit 0

