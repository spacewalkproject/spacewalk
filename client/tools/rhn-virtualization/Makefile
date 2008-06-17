SUBDIRS = actions virtualization scripts
PYFILES = $(wildcard *.py)

PKGNAME = rhn-virtualization
VERSION = $(shell echo `awk '{ print $$1 }' version`)
RELEASE = $(shell echo `awk '{ print $$2 }' version`)
PYTHON=python

all: subdirs

clean:
	rm -f *.pyc *.pyo *~ *.bak *.tar.gz
	for d in $(SUBDIRS); do make -C $$d clean ; done

subdirs:
	for d in $(SUBDIRS); do make PYTHON=$(PYTHON) -C $$d; [ $$? = 0 ] || exit 1 ; done

install:
	for d in $(SUBDIRS); do make PYTHON=$(PYTHON) DESTDIR=$(DESTDIR) -C $$d install; [ $$? = 0 ] || exit 1; done

archive: _archive

_archive:
	@rm -rf ${PKGNAME}-%{VERSION}.tar.gz
	@rm -rf /tmp/${PKGNAME}-$(VERSION) /tmp/${PKGNAME}
	@dir=$$PWD; cd /tmp; cp -a $$dir ${PKGNAME}
	@mv /tmp/${PKGNAME} /tmp/${PKGNAME}-$(VERSION)
	@dir=$$PWD; cd /tmp; tar cvzf $$dir/${PKGNAME}-$(VERSION).tar.gz ${PKGNAME}-$(VERSION)
	@rm -rf /tmp/${PKGNAME}-$(VERSION)	
	@echo "The archive is in ${PKGNAME}-$(VERSION).tar.gz"

rpm: archive
	rpmbuild -ta ${PKGNAME}-$(VERSION).tar.gz

