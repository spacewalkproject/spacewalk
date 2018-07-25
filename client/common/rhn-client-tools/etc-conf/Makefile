# Makefile for Update Agent
#

PREFIX		?=

CONFIG		= up2date.config

# Directories for installation
PAMD_DIR	= $(PREFIX)/etc/pam.d
SECURITY_DIR	= $(PREFIX)/etc/security/console.apps
CONFIG_DIR	= $(PREFIX)/etc/sysconfig/rhn
MACROS_DIR	= $(PREFIX)/etc/rpm/
CAPS_DIR	= $(PREFIX)/etc/sysconfig/rhn/clientCaps.d
ALLOWED_ACTIONS_SCRIPT = $(PREFIX)/etc/sysconfig/rhn/allowed-actions/script
ALLOWED_ACTIONS_CONFIG = $(PREFIX)/etc/sysconfig/rhn/allowed-actions/configfiles
LOGROTATE_DIR	= $(PREFIX)/etc/logrotate.d
YUM_REPO_DIR    = $(PREFIX)/etc/yum.repos.d

# all dirs
DIRS		= $(PAMD_DIR) $(SECURITY_DIR) $(CONFIG_DIR) \
		  $(LOGROTATE_DIR) $(YUM_REPO_DIR)\
		  $(MACROS_DIR) $(CAPS_DIR) $(ALLOWED_ACTIONS_SCRIPT) \
                  $(ALLOWED_ACTIONS_CONFIG)

# INSTALL scripts 
INSTALL         = install -p --verbose 
INSTALL_DIR     = $(INSTALL) -m 755 -d 
INSTALL_DATA    = $(INSTALL) -m 644 

all::

$(DIRS):
	@$(INSTALL_DIR) $@

install:: all $(DIRS)
	$(INSTALL_DATA) up2date.pam $(PAMD_DIR)/rhn_register

	$(INSTALL_DATA) rhn_register.console $(SECURITY_DIR)/rhn_register

	[ -f $(CONFIG_DIR)/up2date ] && true || \
		$(INSTALL_DATA) $(CONFIG) $(CONFIG_DIR)/up2date

	$(INSTALL_DATA) up2date.logrotate $(LOGROTATE_DIR)/up2date

clean::
	@rm -fv *~ .*~
	@find . -name .\#\* -exec rm -fv {} \;
