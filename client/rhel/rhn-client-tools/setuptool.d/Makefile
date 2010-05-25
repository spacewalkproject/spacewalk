
PREFIX		?=

SETUPTOOLDIR		= $(PREFIX)/usr/share/setuptool/setuptool.d

# INSTALL scripts 
INSTALL         = install -p --verbose 
INSTALL_DIR     = $(INSTALL) -m 755 -d 
INSTALL_DATA    = $(INSTALL) -m 644 

all::

$(SETUPTOOLDIR):
	@$(INSTALL_DIR) $@

install:: $(SETUPTOOLDIR)
	$(INSTALL_DATA) 99rhn_register $(SETUPTOOLDIR)

clean::

