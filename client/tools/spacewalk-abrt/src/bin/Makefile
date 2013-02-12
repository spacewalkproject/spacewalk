BIN_DIR         := $(PREFIX)/usr/bin
DIRS            = $(BIN_DIR)

INSTALL         := install -p --verbose
INSTALL_DIR     = $(INSTALL) -m 755 -d
INSTALL_BIN     := $(INSTALL) -m 755

$(DIRS):
	@$(INSTALL_DIR) $@

all:
	echo "Nothing to do"

install:: all $(DIRS)
	$(INSTALL_BIN) spacewalk-abrt $(BIN_DIR)/spacewalk-abrt

clean::
	@rm -fv *.pyc *~ .*~
