# The rhn-client-tools Makefiles might not be set up in the smartest way. This
# Makefile doesn't worry about anything outside of this directory even if these
# files need them, such as the glade files. Be sure to run make in 
# rhn-client-tools and not here.

PYCHECKER       := /usr/bin/pychecker

BIN_DIR		:= $(PREFIX)/usr/bin
SBIN_DIR	:= $(PREFIX)/usr/sbin

INSTALL         := install -p --verbose 
INSTALL_DIR     = $(INSTALL) -m 755 -d 
INSTALL_BIN     := $(INSTALL) -m 755 

DIRS		= $(BIN_DIR) $(SBIN_DIR)
# default compile rule:
%.pyc: %.py
	python -c "import py_compile; py_compile.compile('$<')"

$(DIRS):
	@$(INSTALL_DIR) $@

all:
	echo "Nothing to do"

install:: all $(DIRS)
	$(INSTALL_BIN) rhnreg_ks.py $(SBIN_DIR)/rhnreg_ks
	$(INSTALL_BIN) rhn_register.py $(SBIN_DIR)/rhn_register
	$(INSTALL_BIN) rhn-profile-sync.py $(SBIN_DIR)/rhn-profile-sync
	$(INSTALL_BIN) rhn_check.py $(SBIN_DIR)/rhn_check
	$(INSTALL_BIN) spacewalk-channel.py $(SBIN_DIR)/spacewalk-channel

	ln -sf consolehelper $(BIN_DIR)/rhn_register
	ln -s spacewalk-channel $(SBIN_DIR)/rhn-channel

# OTHER targets for internal use
pychecker:: 
	@$(PYCHECKER) $(PYFILES) || exit 0
graphviz:: 
	@$(PYCHECKER) -Z $(PYFILES) || exit 0

clean::
	@rm -fv *.pyc *~ .*~
