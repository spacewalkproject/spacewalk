# Makefile for RHN Proxy Server Installer
# 
# $Id: Makefile,v 1.18 2004/08/30 23:46:13 taw Exp $

FILES		= __init__ gui rhn_rpm pi_config translate pi \
		  pi_errors pi_lib pi_log ssl_cert_gen rhn_proxy_activate

GLADEFILES	= $(wildcard *.glade)
PNGFILES	= $(wildcard *.png)
CONFFILES	= httpd.conf.sample

PYFILES		= $(addsuffix .py, $(FILES))
PYCFILES	= $(addsuffix .pyc, $(FILES))

OBJECTS		= $(PYFILES) $(PYCFILES)

PROGRAM		= install.sh

# What other subdirs we need to take care of
# XXX: for now we're not translated so we don't bother
SUBDIRS		= # po

# INSTALL scripts
INSTALL		= install
INSTALL_BIN	= $(INSTALL) -m 755
INSTALL_DIR	= $(INSTALL) -m 755 -d
INSTALL_DATA	= $(INSTALL) -m 644

# Where do we deploy?
IMAGE_INSTALL	= $(IMAGE_DIR)/install

# compile target
all::  $(OBJECTS)

# default compile rule:
%.pyc: %.py
	python -c "import py_compile; py_compile.compile('$<')"

# checks that we're called with the proper variables defined
check-env :
	@if [ -z "$(IMAGE_DIR)" -o \
	      -z "$(VERSION)" -o -z "$(RELEASE)" ] ; then \
	    echo ; \
	    echo "ERROR: Parent Makefile needs to invoke me for this target" ;\
	    echo ; \
	    exit -1 ; \
	fi

$(IMAGE_INSTALL) : check-env
	@$(INSTALL_DIR) $@

install:: all check-env $(IMAGE_INSTALL)
	$(INSTALL_DATA) $(OBJECTS) $(PNGFILES) $(GLADEFILES) $(CONFFILES) $(IMAGE_INSTALL)
	$(INSTALL_BIN) $(PROGRAM) $(IMAGE_DIR)/$(PROGRAM)

clean::
	@rm -fv *.pyc *~ .*~ *.bak
	@rm -fv *.rpm

# useful macro
descend-subdirs = @$(foreach d,$(SUBDIRS), $(MAKE) -C $(d) $@ || exit 1; )

# Now do the same in the subdirs
all clean install::
	$(descend-subdirs)


# Compilation and debugging stuff
PYCHECKER	= /usr/bin/pychecker

pychecker::
	@$(PYCHECKER) $(PYFILES) || exit 0


