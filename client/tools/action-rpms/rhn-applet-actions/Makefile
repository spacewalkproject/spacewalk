INSTALL= /usr/bin/install -c
INSTALL_DIR     = $(INSTALL) -m 755 -d 
INSTALL_MODULE	= ${INSTALL} -m 755
INSTALL_CAPS	= ${INSTALL} -m 664

FILES		= rhn_applet
PYFILES 	= $(addsuffix .py, $(FILES))
PYCFILES	= $(addsuffix .pyc, $(FILES))

OBJECTS		= $(PYFILES) $(PYCFILES)

CAPS		= rhn_applet

RHNSHARE_DIR	= $(PREFIX)/usr/share/rhn
RHNCONF_DIR	= $(PREFIX)/etc/sysconfig/rhn

# Handy defines 
VERSION         = $(shell echo `awk '{ print $$1 }' version`)


all: $(OBJECTS)
	$(descend-subdirs)

clean::
	@rm -fv *.pyc *~ .*~ *.o *.so core* *.desktop
	$(descend-subdirs)

# default compile rule:
%.pyc: %.py
	python -c "import py_compile; py_compile.compile('$<')"

install:	all
	$(INSTALL_DIR) $(RHNSHARE_DIR)/actions
	$(INSTALL_MODULE) $(PYFILES) $(RHNSHARE_DIR)/actions/
	$(INSTALL_MODULE) $(PYCFILES) $(RHNSHARE_DIR)/actions/

	$(INSTALL_DIR) $(RHNCONF_DIR)/clientCaps.d
	$(INSTALL_CAPS) $(CAPS) $(RHNCONF_DIR)/clientCaps.d/$(CAPS)

tardist: clean
	rm -Rfv /tmp/rhn-applet-actions-$(VERSION)
	cp -fapRdv . /tmp/rhn-applet-actions-$(VERSION)
	tar zcfv rhn-applet-actions-$(VERSION).tar.gz --exclude CVS -C /tmp rhn-applet-actions-$(VERSION)
