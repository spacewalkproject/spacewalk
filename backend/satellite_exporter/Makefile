# Makefile for the backend directory
#

CODE_DIRS = handlers

SUBDIR      = satellite_exporter
FILES       = __init__ constants satexport

TOP     = ..

# We look for config files in "well known" locations (rhn-conf,
# httpd-conf, logrotate)
EXTRA_DIRS = /var/log/rhn /var/cache/rhn

all :: all-code

%-code : Makefile
	@$(foreach d,$(CODE_DIRS), $(MAKE) -C $(d) $* || exit 1; ) 

include $(TOP)/Makefile.defs

install :: install-code

clean :: clean-code
	@rm -f *pyc
	@rm -f *pyo
