PREFIX          ?=

ABRT_DIR        = $(PREFIX)/etc/libreport/events.d
CAPS_DIR        = $(PREFIX)/etc/sysconfig/rhn/clientCaps.d
DIRS            = $(ABRT_DIR) $(CAPS_DIR)

INSTALL         = install -p --verbose
INSTALL_DIR     = $(INSTALL) -m 755 -d
INSTALL_DATA    = $(INSTALL) -m 644

all::

$(DIRS):
	@$(INSTALL_DIR) $@

install:: all $(DIRS)
	$(INSTALL_DATA) spacewalk.conf $(ABRT_DIR)
	$(INSTALL_DATA) abrt $(CAPS_DIR)

clean::
	@rm -fv *~ .*~
	@find . -name .\#\* -exec rm -fv {} \;
