# Makefile for installing man pages for the up2date client
#

MODULES		= rhn_login_gui \
		  rhn_register_firstboot_gui_window \
		  rhn_start_gui rhn_choose_server_gui \
		  rhn_provide_certificate_gui rhn_create_profile_gui \
		  rhn_review_gui rhn_finish_gui rhn_choose_channel
PYFILES		= $(addsuffix .py, $(MODULES))
OBJECTS		= $(PYFILES)

# Install stuff
INSTALL         = /usr/bin/install -c
INSTALL_DATA     = $(INSTALL) -m 644
INSTALL_DIR     = $(INSTALL) -m 755 --verbose -d

# Install Directories
FIRSTBOOTDIR	= $(PREFIX)/usr/share/firstboot/modules/


PYCHECKER       = /usr/bin/pychecker

all:: $(OBJECTS)

install: all $(FIRSTBOOTDIR)
	$(INSTALL_DATA) $(OBJECTS) $(FIRSTBOOTDIR)/

$(FIRSTBOOTDIR) : 
	@$(INSTALL_DIR) $@

clean:
	@rm -rf *.pyc *~ .*~ *.o

pychecker::
	@$(PYCHECKER) $(PYFILES) || exit 0

