
PREFIX		?=

DIR		= /usr/share/setuptool/setuptool.d

# INSTALL scripts 
INSTALL         = install -p --verbose 
INSTALL_DIR     = $(INSTALL) -m 755 -d 
INSTALL_DATA    = $(INSTALL) -m 644 

all::

$(DIR):
	@$(INSTALL_DIR) $(PREFIX)$@

install:: $(DIR)
	$(INSTALL_DATA) 99rhn_register $(PREFIX)$(DIR)

clean::

